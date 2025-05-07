import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const encoder = new TextEncoder();

function base64UrlEncode(buffer) {
  return btoa(String.fromCharCode(...buffer))
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=+$/, '');
}

function createVapidHeaders(audience, subject, publicKey, privateKey) {
  const expiration = Math.floor(Date.now() / 1000) + 12 * 60 * 60; // 12 hours from now
  const tokenHeader = {
    alg: 'ES256',
    typ: 'JWT',
  };
  const tokenPayload = {
    aud: audience,
    exp: expiration,
    sub: subject,
  };

  function encode(obj) {
    return base64UrlEncode(encoder.encode(JSON.stringify(obj)));
  }

  const headerEncoded = encode(tokenHeader);
  const payloadEncoded = encode(tokenPayload);

  // Note: Proper ES256 signing is required here for production.
  // This is a placeholder with empty signature.
  const signature = '';

  const jwt = `${headerEncoded}.${payloadEncoded}.${signature}`;

  return {
    Authorization: `WebPush ${jwt}`,
    'Crypto-Key': `p256ecdsa=${publicKey}`,
  };
}

async function sendWebPush(subscription, payload) {
  const body = JSON.stringify({
    title: payload.title,
    body: payload.body,
  });

  const VAPID_PUBLIC_KEY = Deno.env.get('VAPID_PUBLIC_KEY') || '';
  const VAPID_PRIVATE_KEY = Deno.env.get('VAPID_PRIVATE_KEY') || '';
  const VAPID_SUBJECT = 'mailto:your-email@example.com';

  const headers = {
    TTL: '60',
    'Content-Type': 'application/json',
    ...createVapidHeaders(
      new URL(subscription.endpoint).origin,
      VAPID_SUBJECT,
      VAPID_PUBLIC_KEY,
      VAPID_PRIVATE_KEY,
    ),
  };

  const response = await fetch(subscription.endpoint, {
    method: 'POST',
    headers,
    body,
  });

  if (!response.ok) {
    throw new Error(`Failed to send push notification: ${response.statusText}`);
  }
}

serve(async (req) => {
  if (req.method !== 'POST') {
    return new Response('Method Not Allowed', { status: 405 });
  }
  try {
    const { title, body } = await req.json();
    if (!title || !body) {
      return new Response('Missing title or body in request', { status: 400 });
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL');
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
    if (!supabaseUrl || !supabaseKey) {
      return new Response('Supabase environment variables not set', { status: 500 });
    }
    const supabase = createClient(supabaseUrl, supabaseKey);

    // Fetch all push subscriptions
    const { data: subscriptions, error } = await supabase.from('push_subscriptions').select('*');
    if (error) {
      console.error('Error fetching subscriptions:', error);
      return new Response('Error fetching subscriptions', { status: 500 });
    }
    if (!subscriptions || subscriptions.length === 0) {
      return new Response('No subscriptions found', { status: 404 });
    }

    // Send push notification to each subscription
    const results = [];
    for (const sub of subscriptions) {
      try {
        const subscription = {
          endpoint: sub.endpoint,
          keys: {
            p256dh: sub.keys_p256dh,
            auth: sub.keys_auth,
          },
        };
        await sendWebPush(subscription, { title, body });
        results.push({ endpoint: sub.endpoint, status: 'sent' });
      } catch (err) {
        console.error('Error sending notification to', sub.endpoint, err);
        results.push({ endpoint: sub.endpoint, status: 'failed', error: err.message });
      }
    }

    return new Response(JSON.stringify({ message: 'Push notifications sent', results }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    });
  } catch (err) {
    console.error('Error in send_push_notification function:', err);
    return new Response('Internal Server Error', { status: 500 });
  }
});