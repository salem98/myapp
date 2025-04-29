# Supabase Package Update Instructions

## Current Version
Your project is currently using `supabase_flutter: ^2.0.0` as specified in your pubspec.yaml file.

## Latest Version
The latest version of supabase_flutter is `2.3.4` (as of my knowledge cutoff).

## Update Steps

1. Open your `pubspec.yaml` file
2. Locate the following line:
   ```yaml
   supabase_flutter: ^2.0.0
   ```
3. Update it to:
   ```yaml
   supabase_flutter: ^2.3.4
   ```
4. Save the file
5. Run the following command in your terminal:
   ```bash
   flutter pub get
   ```
6. Verify the update was successful by running:
   ```bash
   flutter pub outdated
   ```

## Breaking Changes to Watch For

When updating from version 2.0.0 to 2.3.4, be aware of potential breaking changes:

1. Authentication methods might have changed
2. Database query syntax could have been updated
3. Real-time subscription APIs might have been modified

After updating, test your application thoroughly to ensure all Supabase functionality works as expected.

## Additional Resources
- [Supabase Flutter SDK Documentation](https://supabase.com/docs/reference/dart/introduction)
- [Supabase Flutter GitHub Repository](https://github.com/supabase/supabase-flutter)
- [Pub.dev Package Page](https://pub.dev/packages/supabase_flutter)