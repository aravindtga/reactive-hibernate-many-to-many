#! /bin/bash
#
# ============LICENSE_START=======================================================
# Copyright (C) 2024 Ericsson
# Modifications Copyright (C) 2024 OpenInfra Foundation Europe
# ================================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0
# ============LICENSE_END=========================================================
#
KAFKA_NAMESPACE="${1:-teiv}"
KAFKA_TOPIC="${2:-topology-inventory-ingestion}"
KAFKA_POD_NAME="${3:-kafka-0}"
FILE_DUPLICATION_FACTOR="${4:-1}" # How many times to use the same CloudEvent file
FOLDER_OF_CLOUDEVENTS="${5:-events}" # All files in this folder are written to kafka
# number of generated files == number of files in the $FOLDER_OF_CLOUDEVENTS * $FILE_DUPLICATION_FACTOR

echo "Producing messages to Kafka topic '$KAFKA_TOPIC'..."

# Loop to produce multiple messages
for ((i=0; i<$FILE_DUPLICATION_FACTOR; i++)); do
  for file in "$FOLDER_OF_CLOUDEVENTS"/*; do
    if [ -f "$file" ]; then
    echo -e "file is $file\n"
      # Replace the new line characters with a space and write to kafka
      sed ':a;N;$!ba;s/\n/ /g' "$file" | \
        kafka-console-producer --broker-list oran-strimzi-kafka-bootstrap:9092 --topic "$KAFKA_TOPIC" --producer.config producer.properties \
        --property parse.headers=true --property headers.key.separator=::: --property headers.delimiter=,,, --property parse.key=false
    fi
  done
  echo "$((i+1))/$FILE_DUPLICATION_FACTOR rounds completed"
done

echo "Message production completed."
