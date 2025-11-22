// Flutter Web Bootstrap
// This file bootstraps the Flutter web application

// Initialize when DOM is ready
function bootstrapFlutter() {
  if (window._flutter_initialized) {
    return;
  }
  
  window._flutter_initialized = true;
  
  // Load the main Dart script
  const script = document.createElement('script');
  script.src = 'main.dart.js';
  script.type = 'application/javascript';
  
  script.onload = function() {
    console.log('Flutter web app loaded successfully');
  };
  
  script.onerror = function(e) {
    console.error('Failed to load Flutter web app:', e);
    // Show a user-friendly error message
    document.body.innerHTML = '<div style="display: flex; justify-content: center; align-items: center; height: 100vh; font-family: Arial, sans-serif;">' +
                              '<div style="text-align: center;">' +
                              '<h1>BYTE Voting System</h1>' +
                              '<p>Failed to load the application. Please refresh the page.</p>' +
                              '<button onclick="location.reload()" style="padding: 10px 20px; background: #2196F3; color: white; border: none; border-radius: 4px; cursor: pointer;">Refresh</button>' +
                              '</div></div>';
  };
  
  document.body.appendChild(script);
}

// Initialize when DOM is ready
if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", bootstrapFlutter);
} else {
  bootstrapFlutter();
}