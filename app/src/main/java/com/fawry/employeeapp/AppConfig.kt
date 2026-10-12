package com.fawry.employeeapp

object SupabaseConfig {
    const val URL = "https://YOUR-PROJECT.supabase.co"
    const val ANON_KEY = "YOUR_SUPABASE_ANON_OR_PUBLISHABLE_KEY"
    fun configured(): Boolean = !URL.contains("YOUR-PROJECT") && !ANON_KEY.startsWith("YOUR_")
}
