#!/bin/bash

# Configuration
BURST_COUNT=3
SHOT_COUNT=5
SHOT_INTERVAL=10
BURST_INTERVAL=120
OUTPUT_DIR="$HOME/scrotshot"
LOG_FILE="$OUTPUT_DIR/scrotshot.log"
EMAIL_TO="root@localhost"
EMAIL_CC="jeremy@localhost"
SUBJECT_PREFIX="Scrotshot Reminders"

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Log function
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to send email
send_email() {
    log "Sending email for burst $1..."
    # Attach all screenshots in the OUTPUT_DIR
    if mail -s "$SUBJECT_PREFIX (Burst $1)" -c "$EMAIL_CC" "$EMAIL_TO" <<< "Please find attached the screenshots taken every 2 minutes." -A "$OUTPUT_DIR"/*.png; then
        log "Email sent successfully."
    else
        log "Failed to send email."
    fi
}

# Capture screenshots and send email
for ((burst=1; burst <= BURST_COUNT; burst++)); do
    log "Starting burst $burst..."
    
    sleep 2  # Add a short delay before the first screenshot
    
    for ((count=1; count <= SHOT_COUNT; count++)); do
        timestamp=$(date +%Y-%m-%d_%H-%M-%S)
        simple_timestamp=$(date +%Y%m%d_%H%M%S)
        filename="$OUTPUT_DIR/screenshot_${burst}_${count}_${simple_timestamp}.png"
        
        log "Attempting to save screenshot to $filename"
        
        if scrot "$filename"; then
            log "Screenshot $count in burst $burst saved: $filename at $timestamp"
        else
            log "Failed to take screenshot $count in burst $burst."
        fi
        
        sleep $SHOT_INTERVAL
    done
    
    send_email "$burst"

    # Clean up the screenshots after sending
    rm "$OUTPUT_DIR"/*.png
    
    if [[ $burst -lt $BURST_COUNT ]]; then
        log "Sleeping for $BURST_INTERVAL seconds before the next burst..."
        sleep $BURST_INTERVAL
    fi
done

log "All bursts completed."
