puts "Seeding indications..."
diabetes    = Indication.find_or_create_by!(name: "Diabetes")
hair_loss   = Indication.find_or_create_by!(name: "Hair Loss")
hypertension = Indication.find_or_create_by!(name: "Hypertension")
anxiety     = Indication.find_or_create_by!(name: "Anxiety")

puts "Seeding doctors..."
dr_smith = Doctor.find_or_create_by!(email: "smith@wellster.com") do |d|
  d.first_name = "John"
  d.last_name  = "Smith"
end
dr_smith.indications = [diabetes, hypertension]

dr_jones = Doctor.find_or_create_by!(email: "jones@wellster.com") do |d|
  d.first_name = "Sarah"
  d.last_name  = "Jones"
end
dr_jones.indications = [hair_loss, anxiety]

puts "Seeding patients..."
patients_data = [
  { first_name: "Alice",  last_name: "Brown",  email: "alice@example.com",  indication: diabetes },
  { first_name: "Bob",    last_name: "White",  email: "bob@example.com",    indication: diabetes,    doctor: dr_smith },
  { first_name: "Carol",  last_name: "Adams",  email: "carol@example.com",  indication: hair_loss },
  { first_name: "David",  last_name: "Miller", email: "david@example.com",  indication: hypertension },
  { first_name: "Eve",    last_name: "Taylor", email: "eve@example.com",    indication: anxiety,     doctor: dr_jones },
  { first_name: "Frank",  last_name: "Clark",  email: "frank@example.com",  indication: anxiety },
]

patients_data.each do |attrs|
  Patient.find_or_create_by!(email: attrs[:email]) do |p|
    p.first_name  = attrs[:first_name]
    p.last_name   = attrs[:last_name]
    p.indication  = attrs[:indication]
    p.doctor      = attrs[:doctor]
  end
end

puts "Seeding appointments..."
bob = Patient.find_by!(email: "bob@example.com")
Appointment.find_or_create_by!(patient: bob, scheduled_at: 3.days.from_now) { |a| a.doctor = bob.doctor }
Appointment.find_or_create_by!(patient: bob, scheduled_at: 10.days.from_now) { |a| a.doctor = bob.doctor }

eve = Patient.find_by!(email: "eve@example.com")
Appointment.find_or_create_by!(patient: eve, scheduled_at: 1.day.from_now) { |a| a.doctor = eve.doctor }

puts "Done! #{Indication.count} indications, #{Doctor.count} doctors, #{Patient.count} patients, #{Appointment.count} appointments."
