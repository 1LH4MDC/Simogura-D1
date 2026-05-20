# Simogura WebSocket Bridge

This is a standalone bridge that synchronizes data between Supabase (PostgreSQL Realtime) and HiveMQ (MQTT over WebSockets).

## Features
- **MQTT to Supabase**: Listens to the `simogura/data/incoming` topic and inserts messages into the `data_sensor` table in Supabase.
- **Supabase to MQTT**: Listens for new inserts in the `data_sensor` table and publishes them to `simogura/sensors/{kolam_id}`.

## Prerequisites
- Node.js installed.
- Supabase project with a `data_sensor` table.
- HiveMQ Cloud account.

## Setup
1. Navigate to this directory:
   ```bash
   cd bridge
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. The `.env` file is already configured with:
   - `SUPABASE_URL`: Your Supabase Project URL.
   - `SUPABASE_SERVICE_ROLE_KEY`: Your Supabase Service Role Secret.
   - `HIVEMQ_WS_URL`: Your HiveMQ WebSocket URL.

## Running the Bridge
Start the bridge using:
```bash
node bridge.js
```

## Expected Database Schema
The bridge assumes a table named `data_sensor` with at least these columns:
- `kolam_id` (UUID)
- `ph` (Numeric)
- `temp` (Numeric)
- `ketinggian` (Numeric)
- `amonia` (Numeric)
- `created_at` (Timestamptz)
