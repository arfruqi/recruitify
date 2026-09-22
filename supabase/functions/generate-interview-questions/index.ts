// Supabase Edge Function: generate-interview-questions
// Called once, right when a recruiter posts a new job. Generates a set of
// tailored interview questions from the job's requirements, stored so
// every candidate who applies answers the SAME set of questions.

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { jobId } = await req.json();
    if (!jobId) {
      throw new Error('jobId is required');
    }

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    );

    const { data: job, error: jobError } = await supabaseAdmin
      .from('jobs')
      .select('title, description, requirements')
      .eq('id', jobId)
      .single();

    if (jobError || !job) {
      throw new Error(`Could not find job: ${jobError?.message}`);
    }

    const promptText = `You are helping a recruiter design an initial screening interview.

Based on the job below, write exactly 5 short interview questions specifically tailored to this role's requirements. Mix in both technical questions (about the specific skills/tools mentioned) and a couple of general fit/experience questions. Keep each question concise (one sentence).

Return ONLY a JSON object (no markdown, no code fences, no extra text) in exactly this shape:
{"questions": ["question 1", "question 2", "question 3", "question 4", "question 5"]}

JOB TITLE: ${job.title}
JOB DESCRIPTION: ${job.description}
JOB REQUIREMENTS: ${job.requirements}`;

    const geminiResponse = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-3.6-flash:generateContent?key=${Deno.env.get('GEMINI_API_KEY')}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          contents: [{ parts: [{ text: promptText }] }],
        }),
      },
    );

    const geminiData = await geminiResponse.json();
    const rawText: string = geminiData.candidates?.[0]?.content?.parts?.[0]?.text ?? '';

    if (!rawText) {
      throw new Error(`Gemini returned no usable response: ${JSON.stringify(geminiData)}`);
    }

    const cleaned = rawText.replace(/```json/g, '').replace(/```/g, '').trim();
    const parsed = JSON.parse(cleaned);
    const questions: string[] = parsed.questions ?? [];

    if (questions.length === 0) {
      throw new Error('Gemini did not return any questions');
    }

    // Insert one row per question, all tied to this job.
    const rows = questions.map((q) => ({ job_id: jobId, question_text: q }));
    const { error: insertError } = await supabaseAdmin.from('interview_questions').insert(rows);

    if (insertError) {
      throw new Error(`Could not save questions: ${insertError.message}`);
    }

    return new Response(
      JSON.stringify({ questions }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  }
});