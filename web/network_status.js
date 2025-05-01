// Network Status Checker for TNS Express PWA

(function() {
  // Get references to DOM elements we'll need to update
  let statusIndicator = null;
  let statusMessage = null;
  
  // Initialize the network status checker
  function init() {
    // Create status indicator elements if they don't exist
    createStatusElements();
    
    // Set initial status
    updateOnlineStatus();
    
    // Add event listeners for online/offline events
    window.addEventListener('online', updateOnlineStatus);
    window.addEventListener('offline', updateOnlineStatus);
  }
  
  // Create status indicator elements
  function createStatusElements() {
    // Create container
    const container = document.createElement('div');
    container.id = 'network-status';
    container.style.cssText = `
      position: fixed;
      bottom: 20px;
      right: 20px;
      background-color: rgba(0, 0, 0, 0.7);
      color: white;
      padding: 8px 16px;
      border-radius: 20px;
      font-family: Arial, sans-serif;
      font-size: 14px;
      display: flex;
      align-items: center;
      z-index: 9999;
      transition: opacity 0.3s, transform 0.3s;
      opacity: 0;
      transform: translateY(20px);
      pointer-events: none;
    `;
    
    // Create status indicator
    statusIndicator = document.createElement('span');
    statusIndicator.style.cssText = `
      display: inline-block;
      width: 10px;
      height: 10px;
      border-radius: 50%;
      margin-right: 8px;
    `;
    
    // Create status message
    statusMessage = document.createElement('span');
    
    // Append elements
    container.appendChild(statusIndicator);
    container.appendChild(statusMessage);
    
    // Add to body when DOM is ready
    if (document.body) {
      document.body.appendChild(container);
    } else {
      window.addEventListener('DOMContentLoaded', () => {
        document.body.appendChild(container);
      });
    }
  }
  
  // Update the status indicator based on online/offline status
  function updateOnlineStatus() {
    if (!statusIndicator || !statusMessage) return;
    
    const container = document.getElementById('network-status');
    if (!container) return;
    
    if (navigator.onLine) {
      statusIndicator.style.backgroundColor = '#4CAF50'; // Green
      statusMessage.textContent = 'Online';
      
      // Show the indicator briefly then hide it
      container.style.opacity = '1';
      container.style.transform = 'translateY(0)';
      
      setTimeout(() => {
        container.style.opacity = '0';
        container.style.transform = 'translateY(20px)';
      }, 3000);
    } else {
      statusIndicator.style.backgroundColor = '#F44336'; // Red
      statusMessage.textContent = 'Offline';
      
      // Keep the indicator visible when offline
      container.style.opacity = '1';
      container.style.transform = 'translateY(0)';
    }
  }
  
  // Initialize when the page loads
  if (document.readyState === 'loading') {
    window.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();