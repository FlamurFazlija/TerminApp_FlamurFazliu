import { createClient } from '@supabase/supabase-js'

export function useSupabase() {
  const config = useRuntimeConfig()

  const url = String(config.public.supabaseUrl)
  const key = String(config.public.supabaseAnonKey)

  return createClient(url, key)
}