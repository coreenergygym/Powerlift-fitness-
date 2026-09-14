

## POWER LIFT FITNESS — Final Scope
- Public site: gym information, facilities, editable membership plans, gallery, enquiries, contact, WhatsApp, Instagram and Maps.
- Admin login is visible from the public header and mobile menu.
- Admin: gym details, timings, branding (logo/hero upload), facilities, plans, gallery upload/edit/delete, enquiry management, password change and logout.
- Steam Bath ₹250 is included as an editable plan.
- Confirmed readable membership terms are seeded in `gym_terms`.
- No customer login, member management, payment management or online payments.
- Storage uses Supabase buckets `branding` and `gallery`; never put a service-role key in the frontend.
