# Keep TensorFlow Lite classes for GPU delegate
-keep class org.tensorflow.** { *; }
-keep class org.tensorflow.lite.gpu.** { *; }
-dontwarn org.tensorflow.lite.gpu.GpuDelegateFactory$Options