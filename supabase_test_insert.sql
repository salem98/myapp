INSERT INTO notifications (title, message, created_at)
VALUES (
  'Test Notification',
  'This is a Supabase RT test at ' || NOW(),
  NOW()
);