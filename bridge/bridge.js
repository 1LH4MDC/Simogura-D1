require('dotenv').config();
const { createClient } = require('@supabase/supabase-js');
const mqtt = require('mqtt');

// Configuration from .env
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
const hivemqWsUrl = process.env.HIVEMQ_WS_URL;

// Initialize Supabase Client
const supabase = createClient(supabaseUrl, supabaseServiceKey);

// Initialize MQTT Client (WebSocket)
const mqttClient = mqtt.connect(hivemqWsUrl, {
    clientId: 'simogura_bridge_' + Math.random().toString(16).substring(2, 8),
    clean: true,
    connectTimeout: 4000,
    reconnectPeriod: 1000,
});

mqttClient.on('connect', () => {
    console.log('Connected to HiveMQ Cloud via WebSocket');
    // Subscribe to incoming sensor data from devices
    mqttClient.subscribe('simogura/data/incoming', (err) => {
        if (!err) {
            console.log('Subscribed to topic: simogura/data/incoming');
        }
    });
});

mqttClient.on('error', (err) => {
    console.error('MQTT Connection Error:', err);
});

// 1. MQTT -> Supabase: Listen for messages and save to DB
mqttClient.on('message', async (topic, message) => {
    console.log(`Received message on ${topic}: ${message.toString()}`);
    
    if (topic === 'simogura/data/incoming') {
        try {
            const data = JSON.parse(message.toString());
            
            // Mapping based on public.data_sensor schema
            const { error } = await supabase
                .from('data_sensor')
                .insert([
                    {
                        kolam_id: data.kolam_id,
                        ph: data.ph,
                        temp: data.temp,
                        ketinggian: data.ketinggian,
                        amonia: data.amonia,
                        created_at: new Date()
                    }
                ]);

            if (error) {
                console.error('Error inserting to Supabase:', error.message);
            } else {
                console.log('Successfully saved sensor data to Supabase');
            }
        } catch (e) {
            console.error('Failed to parse MQTT message:', e.message);
        }
    }
});

// 2. Supabase -> MQTT: Listen for real-time changes and publish to MQTT
console.log('Setting up Supabase Realtime listeners...');

const channel = supabase
    .channel('public:data_sensor')
    .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'data_sensor' }, (payload) => {
        console.log('New record in Supabase data_sensor:', payload.new);
        
        // Publish the new record to an MQTT topic for other subscribers (like the app)
        const topic = `simogura/sensors/${payload.new.kolam_id || 'all'}`;
        mqttClient.publish(topic, JSON.stringify(payload.new), { qos: 1 }, (err) => {
            if (err) {
                console.error('Error publishing to MQTT:', err);
            } else {
                console.log(`Published to MQTT topic: ${topic}`);
            }
        });
    })
    .subscribe((status) => {
        console.log('Supabase Realtime status:', status);
    });

console.log('Bridge is running. Press Ctrl+C to stop.');
