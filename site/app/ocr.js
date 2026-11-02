// Recognition stays on the device. Only the local OCR engine/model is loaded.
window.knockquestExtractImageText = async function (bytes) {
  if (!window.Tesseract) {
    await new Promise((resolve, reject) => {
      const script = document.createElement('script');
      script.src = new URL('vendor/ocr/tesseract.min.js', document.baseURI).href;
      script.onload = resolve;
      script.onerror = () => reject(new Error('OCR engine could not be loaded. Check your connection.'));
      document.head.appendChild(script);
    });
  }
  const base = new URL('vendor/ocr/', document.baseURI).href;
  const worker = await Tesseract.createWorker('eng', 1, {
    workerPath: base + 'worker.min.js', corePath: base,
    langPath: base, workerBlobURL: false,
  });
  const url = URL.createObjectURL(new Blob([bytes]));
  try {
    const result = await worker.recognize(url);
    return result.data.text;
  } finally {
    URL.revokeObjectURL(url);
    await worker.terminate();
  }
};
