# Wellster API — Doctors Panel

A JSON REST API built with Ruby on Rails that powers the doctor management panel for Wellster, a telemedicine provider. Doctors can view their assigned patients, find new patients they are eligible to treat, and assign themselves to patients.

---

## Tech Stack

- **Ruby** 4.0.3
- **Rails** 8.1
- **PostgreSQL** 15
- **RSpec** + FactoryBot + Shoulda-Matchers (tests)
- **Docker** + Docker Compose

---

## Requirements

- [Docker](https://docs.docker.com/get-docker/) + Docker Compose

---

## Setup

### 1. Clone the repository

```bash
git clone <repository-url>
cd wellster_api
```

### 2. Start the app

First time (or after changing the `Dockerfile` or `Gemfile`):

```bash
docker-compose up --build
```

Day-to-day:

```bash
docker-compose up
```

### 3. Set up the database

First time only:

```bash
docker-compose run web bundle exec rails db:create db:migrate
```

### 4. (Optional) Seed sample data

```bash
docker-compose run web bundle exec rails db:seed
```

This creates:
- 4 indications: Diabetes, Hair Loss, Hypertension, Anxiety
- 2 doctors with pre-assigned indications
- 6 patients (some assigned, some available)
- 3 future appointments

API is available at `http://localhost:3000`.

---

## Running Tests

First time only — create and migrate the test database:

```bash
docker-compose run -e RAILS_ENV=test web bundle exec rails db:create db:migrate
```

Run the test suite:

```bash
docker-compose run -e RAILS_ENV=test web bundle exec rspec
```

Run with detailed output:

```bash
docker-compose run -e RAILS_ENV=test web bundle exec rspec --format documentation
```

---

## API Reference

All endpoints return and accept `application/json`.

---

### 1. List available patients for a doctor

Returns all patients who have **no assigned doctor** and whose indication matches one the doctor is qualified to treat.

```
GET /api/v1/doctors/:doctor_id/available_patients
```

**Response `200 OK`**

```json
[
  {
    "id": 1,
    "first_name": "Alice",
    "last_name": "Brown",
    "email": "alice@example.com",
    "indication": {
      "id": 1,
      "name": "Diabetes"
    }
  }
]
```

---

### 2. List a doctor's assigned patients

Returns all patients currently assigned to the doctor. Supports sorting.

```
GET /api/v1/doctors/:doctor_id/patients
```

**Query Parameters**

| Parameter | Values                                   | Default       |
|-----------|------------------------------------------|---------------|
| `sort`    | `last_name` \| `closest_appointment`    | `last_name`   |

- `last_name` — alphabetical order
- `closest_appointment` — ordered by the earliest **future** appointment; patients with no upcoming appointment appear last

**Response `200 OK`**

```json
[
  {
    "id": 2,
    "first_name": "Bob",
    "last_name": "White",
    "email": "bob@example.com",
    "indication": {
      "id": 1,
      "name": "Diabetes"
    },
    "next_appointment": "2026-04-29T10:00:00.000Z"
  }
]
```

---

### 3. Assign a patient to a doctor

Assigns the specified patient to the doctor if all business rules pass.

```
POST /api/v1/doctors/:doctor_id/patients
```

**Request Body**

```json
{
  "patient": {
    "patient_id": 1
  }
}
```

**Response `201 Created`**

```json
{
  "id": 1,
  "first_name": "Alice",
  "last_name": "Brown",
  "email": "alice@example.com",
  "indication": {
    "id": 1,
    "name": "Diabetes"
  },
  "next_appointment": null
}
```

**Error Responses**

| Status | Reason |
|--------|--------|
| `404 Not Found` | Doctor or patient does not exist |
| `422 Unprocessable Content` | Patient is already assigned to another doctor |
| `422 Unprocessable Content` | Doctor's indications do not cover the patient's diagnosis |

---

## Business Rules

1. **Indication matching** — A doctor may only be assigned to patients whose indication is in the doctor's qualification list.
2. **Exclusive assignment** — A patient may only be treated by one doctor at a time. Once assigned, the patient is no longer visible in any doctor's available patients list.

---

## Project Structure

```
app/
  controllers/
    api/v1/
      base_controller.rb                  # shared error handling
      doctors/
        patients_controller.rb           # GET /patients, POST /patients
        available_patients_controller.rb # GET /available_patients
  models/
    doctor.rb
    patient.rb
    indication.rb
    doctor_indication.rb                 # join table with uniqueness guard
    appointment.rb
spec/
  factories/         # FactoryBot definitions
  models/            # unit tests for scopes, validations, associations
  requests/api/v1/doctors/  # integration tests for all 3 endpoints
```

---

## Assumptions

1. **No authentication in scope.** The doctor is identified by their `:doctor_id` URL parameter. In production this would be replaced by JWT or session-based authentication where the `doctor_id` is derived from the token, not the URL.

2. **Appointment direction for sorting.** "Closest appointment" means the nearest **future** appointment. Past appointments are ignored. Patients with only past appointments or no appointments at all sort to the end.

3. **CORS origins** are configurable via the `CORS_ORIGINS` environment variable (defaults to `*` for development convenience). In production, set this to the specific frontend origin(s).

4. **Deleting an indication nullifies the patient's indication.** The `indication_id` on patients is nullable (`optional: true` in the model), and the association uses `dependent: :nullify`. This preserves the patient record when an indication is removed rather than cascading the delete.

5. **Appointments retain history when a doctor or patient is deleted.** The `doctor_id` and `patient_id` foreign keys on appointments are nullable, and the associations use `dependent: :nullify`. This means deleting a doctor or patient orphans their appointments rather than destroying them, preserving the historical record. As a result, both associations are `optional: true` in the model. Possible future improvements include:
   - Snapshotting the doctor's and patient's names/data directly on the appointment record at creation time, so the record remains meaningful even after nullification.
   - Implementing soft deletes (e.g. via `paranoia` or `discard`) across the app so no records are ever hard-deleted.