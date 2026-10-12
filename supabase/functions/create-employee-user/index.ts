import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

Deno.serve(async (req) => {
  try {
    const auth = req.headers.get('Authorization') ?? ''
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!
    const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const userClient = createClient(supabaseUrl, anonKey, { global: { headers: { Authorization: auth } } })
    const { data: { user } } = await userClient.auth.getUser()
    if (!user) return new Response(JSON.stringify({error:'Unauthorized'}), {status:401})

    const admin = createClient(supabaseUrl, serviceKey)
    const { data: profile } = await admin.from('profiles').select('role,active').eq('id', user.id).single()
    if (!profile?.active || !['admin','manager'].includes(profile.role)) {
      return new Response(JSON.stringify({error:'Manager access required'}), {status:403})
    }

    const { email, password, full_name, employee_code, hire_date, work_location, receipt_limit, pos_limit, notes } = await req.json()
    if (!email || !password || !full_name) return new Response(JSON.stringify({error:'email, password and full_name are required'}), {status:400})

    const { data: created, error: authError } = await admin.auth.admin.createUser({ email, password, email_confirm: true })
    if (authError) throw authError

    const { data: employee, error: employeeError } = await admin.from('employees').insert({full_name,employee_code,hire_date,email,work_location,receipt_limit,pos_limit,notes}).select().single()
    if (employeeError) throw employeeError

    const { error: profileError } = await admin.from('profiles').insert({id: created.user.id, full_name, role:'employee', employee_id:employee.id, active:true})
    if (profileError) throw profileError

    return new Response(JSON.stringify({ok:true, employee_id:employee.id, user_id:created.user.id}), {headers:{'Content-Type':'application/json'}})
  } catch (e) {
    return new Response(JSON.stringify({error: String(e?.message ?? e)}), {status:500,headers:{'Content-Type':'application/json'}})
  }
})
