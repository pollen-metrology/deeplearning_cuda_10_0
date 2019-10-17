import os
import tensorflow as tf

os.environ["CUDA_VISIBLE_DEVICES"] = "0"
sess = tf.Session(config=tf.ConfigProto(log_device_placement=True))
