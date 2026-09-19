// Supabase Edge Function: score-resume
// Runs server-side (Deno runtime) - the Gemini API key is safe here,
// never exposed to the Flutter app itself.
//
// Sends the resume PDF directly to Gemini as multimodal input (no separate
// PDF text-extraction library needed - Gemini reads the PDF itself).
// Returns and stores both a compatibility score AND a short summary.

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { encodeBase64 } from 'https://deno.land/std@0.224.0/encoding/base64.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { applicationId } = await req.json();
    if (!applicationId) {
      throw new Error('applicationId is required');
    }

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    );

    // 1. Fetch the application, and through it, the job it's for.
    const { data: application, error: appError } = await supabaseAdmin
      .from('applications')
      .select('*, jobs(title, description, requirements)')
      .eq('id', applicationId)
      .single();

    if (appError || !application) {
      throw new Error(`Could not find application: ${appError?.message}`);
    }

    const job = application.jobs;

    // 2. Download the actual resume file bytes from Storage.
    const { data: fileBlob, error: downloadError } = await supabaseAdmin.storage
      .from('resumes')
      .download(application.resume_url);

    if (downloadError || !fileBlob) {
      throw new Error(`Could not download resume: ${downloadError?.message}`);
    }

    // 3. Convert to base64 - how a file is sent INLINE in a Gemini request.
    const arrayBuffer = await fileBlob.arrayBuffer();
    const base64Pdf = encodeBase64(new Uint8Array(arrayBuffer));

    // 4. Build the prompt and call Gemini, sending the PDF directly.
    const promptText = `You are a resume screening assistant. Read the attached resume PDF and compare it to the job's requirements below.

Return ONLY a JSON object (no markdown, no code fences, no extra text) in exactly this shape:
{"score": <integer 0-100>, "summary": "<2-3 sentence summary of the candidate's fit for this role, mentioning relevant strengths and any notable gaps>"}

JOB TITLE: ${job.title}
JOB DESCRIPTION: ${job.description}
JOB REQUIREMENTS: ${job.requirements}`;

    // NOTE: model name updated from gemini-2.5-flash (deprecated for new
    // API keys as of testing) to gemini-3.6-flash. If Google deprecates
    // this one too in the future, the error message from Gemini itself
    // will name the current replacement model - same fix, just swap the
    // model name in this URL.
    const geminiResponse = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-3.6-flash:generateContent?key=${Deno.env.get('GEMINI_API_KEY')}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          contents: [{
            parts: [
              { text: promptText },
              {
                inlineData: {
                  mimeType: 'application/pdf',
                  data: base64Pdf,
                },
              },
            ],
          }],
        }),
      },
    );

    const geminiData = await geminiResponse.json();
    const rawText: string = geminiData.candidates?.[0]?.content?.parts?.[0]?.text ?? '';

    if (!rawText) {
      throw new Error(`Gemini returned no usable response: ${JSON.stringify(geminiData)}`);
    }

    // Gemini sometimes wraps JSON in markdown code fences despite being
    // told not to - strip those defensively before parsing.
    const cleaned = rawText.replace(/```json/g, '').replace(/```/g, '').trim();
    const parsed = JSON.parse(cleaned);

    const score = Math.max(0, Math.min(100, Number(parsed.score)));
    const summary: string = parsed.summary ?? '';

    // 5. Auto-reject very low matches, per the original spec.
    const AUTO_REJECT_THRESHOLD = 30;
    const newStatus = score < AUTO_REJECT_THRESHOLD ? 'rejected' : application.status;

    // 6. Write both the score AND summary back to the application row.
    const { error: updateError } = await supabaseAdmin
      .from('applications')
      .update({ ai_score: score, ai_summary: summary, status: newStatus })
      .eq('id', applicationId);

    if (updateError) {
      throw new Error(`Could not save score: ${updateError.message}`);
    }

    return new Response(
      JSON.stringify({ score, summary, autoRejected: newStatus === 'rejected' }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  }
});