
# FIRST ARGUMENT IS NUMBER OF SAMPLES TO SAMPLE (acquisition batch size)

set -e

### change these variables if needed
DATA_DIR=data
# TASK_NAME=imdb
TASK_NAME=joey
MODEL_TYPE=bert
# MODEL_NAME=bert-base-uncased
# MODEL_NAME=KB/bert-base-swedish-cased
# MODEL_NAME=../nlp-nerbootstrap/data/nerblackbox/pretrained_models/LOCAL-KB-bert-base-swedish-cased
MODEL_NAME=../nlp-nerbootstrap/data/nerblackbox/pretrained_models/LOCAL-AF-bert-base-swedish-uncased
SEED=125
COLDSTART=none
SAMPLING=alps
INCREMENT=$1
### end

METHOD=${COLDSTART}-${SAMPLING}
MODEL_DIR=models/${SEED}/${TASK_NAME}
if [ "$COLDSTART" == "none" ]
then
    MODEL0=$MODEL_NAME
    START=0
    METHOD=${SAMPLING}
else
    MODEL0=${MODEL_DIR}/${COLDSTART}_${INCREMENT}
    START=$INCREMENT
fi

active (){
# 1=number of samples
# 2=model path
# 3=sampling method
echo -e "\n\nACQUIRING $1 SAMPLES\n\n"
python -m src.active \
    --model_type $MODEL_TYPE \
    --model_name_or_path $2 \
    --task_name $TASK_NAME \
    --data_dir $DATA_DIR/$TASK_NAME \
    --output_dir ${MODEL_DIR}/${3}_${1} \
    --seed $SEED \
    --query_size $INCREMENT \
    --sampling $SAMPLING \
    --base_model $MODEL_NAME \
    --per_gpu_eval_batch_size 32 \
    --max_seq_length 128
}

echo "Starting ALPS"

f=$MODEL0
p=$(( $START + $INCREMENT ))
active $p $f $METHOD

echo "ALPS done!"
