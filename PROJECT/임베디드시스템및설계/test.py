import cv2
import time
import sys
import numpy as np
import onnxruntime as ort

def build_model(is_cuda):
    providers = ['CUDAExecutionProvider'] if is_cuda else ['CPUExecutionProvider']

    session_options = ort.SessionOptions()
    session_options.graph_optimization_level = ort.GraphOptimizationLevel.ORT_ENABLE_ALL  
    session_options.execution_mode = ort.ExecutionMode.ORT_PARALLEL 

    session_options.enable_profiling = False
    session_options.enable_mem_pattern = True
    session_options.enable_cpu_mem_arena = True
    session_options.execution_order = ort.ExecutionOrder.PRIORITY_BASED

    session_options.intra_op_num_threads = 0
    session_options.inter_op_num_threads = 2 

    net = ort.InferenceSession("config_files/best.onnx", providers=providers)

    if is_cuda:
        print("Attempting to use CUDA")
    else:
        print("Running on CPU")
    return net

INPUT_WIDTH = 640
INPUT_HEIGHT = 640
SCORE_THRESHOLD = 0.2
NMS_THRESHOLD = 0.4
CONFIDENCE_THRESHOLD = 0.4

def detect(image, net):
    blob = cv2.dnn.blobFromImage(image, 1/255.0, (INPUT_WIDTH, INPUT_HEIGHT), swapRB=True, crop=False)
    #blob = blob.astype(np.uint8)
    preds = net.run(None, {net.get_inputs()[0].name: blob})[0]
    return preds

def load_capture():
    capture = cv2.VideoCapture("sample.mp4")
    return capture

def load_classes():
    class_list = []
    with open("config_files/classes.txt", "r") as f:
        class_list = [cname.strip() for cname in f.readlines()]
    return class_list

class_list = load_classes()

def wrap_detection(input_image, output_data):
    class_ids = []
    confidences = []
    boxes = []

    rows = output_data.shape[1]  # Changed to access correct dimension

    image_width, image_height, _ = input_image.shape

    x_factor = image_width / INPUT_WIDTH
    y_factor =  image_height / INPUT_HEIGHT

    for r in range(rows):
        row = output_data[0][r]  # Changed to access correct dimension
        confidence = row[4]
        if confidence >= 0.25:

            classes_scores = row[5:]
            class_id = np.argmax(classes_scores)
            if classes_scores[class_id] > 0.25:

                confidences.append(confidence)
                class_ids.append(class_id)

                x, y, w, h = row[0].item(), row[1].item(), row[2].item(), row[3].item()
                left = int((x - 0.5 * w) * x_factor)
                top = int((y - 0.5 * h) * y_factor)
                width = int(w * x_factor)
                height = int(h * y_factor)
                box = np.array([left, top, width, height])
                boxes.append(box)

    indexes = cv2.dnn.NMSBoxes(boxes, confidences, 0.25, 0.45)

    result_class_ids = []
    result_confidences = []
    result_boxes = []

    if len(indexes) > 0:
        for i in indexes.flatten():
            result_confidences.append(confidences[i])
            result_class_ids.append(class_ids[i])
            result_boxes.append(boxes[i])

    return result_class_ids, result_confidences, result_boxes

def format_yolov5(frame):
    row, col, _ = frame.shape
    _max = max(col, row)
    result = np.zeros((_max, _max, 3), np.uint8)
    result[0:row, 0:col] = frame
    return result

colors = [(255, 255, 0), (0, 255, 0), (0, 255, 255), (255, 0, 0)]

is_cuda = len(sys.argv) > 1 and sys.argv[1] == "cuda"

net = build_model(is_cuda)
capture = load_capture()

start = time.time_ns()
frame_count = 0
total_frames = 0
fps = -1

PreProcessTime = 0
proCessTime = 0
outPutTime = 0

while True:
    T1= time.time()
    _, frame = capture.read()
    if frame is None:
        print("End of stream")
        break
    T2= time.time()
    PreProcessTime += T2 -T1

    frame_count += 1
    total_frames += 1

    if frame_count % 4 != 0:
        inputImage = format_yolov5(frame)
        outs = detect(inputImage, net)
        class_ids, confidences, boxes = wrap_detection(inputImage, outs)
        for (classid, confidence, box) in zip(class_ids, confidences, boxes):
            color = colors[int(classid) % len(colors)]
            cv2.rectangle(frame, box, color, 2)
            cv2.rectangle(frame, (box[0], box[1] - 20), (box[0] + box[2], box[1]), color, -1)
            cv2.putText(frame, class_list[classid], (box[0], box[1] - 10), cv2.FONT_HERSHEY_SIMPLEX, .5, (0,0,0))

    if frame_count >= 30:
        end = time.time_ns()
        fps = 1000000000 * frame_count / (end - start)
        frame_count = 0
        start = time.time_ns()
    
    if fps > 0:
        fps_label = "FPS: %.2f" % fps
        cv2.putText(frame, fps_label, (10, 25), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 0, 255), 2)

    T3 = time.time()
    proCessTime += T3 - T2

    cv2.imshow("output", frame)

    T4 = time.time()

    outPutTime += T4 - T3

    if cv2.waitKey(1) > -1:
        print("finished by user")
        break

total_time = PreProcessTime + proCessTime + outPutTime

print("Total frames: " + str(total_frames))
print(f"{PreProcessTime/total_time:.2f}, {proCessTime/total_time:.2f}, {outPutTime/total_time:.2f}, {total_time:.2f}")