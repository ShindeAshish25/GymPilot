// Mock WhatsApp Service
// In a production environment, this would integrate with Twilio or WhatsApp Business API.

const sendWhatsAppMessage = async (phone, message) => {
  return new Promise((resolve) => {
    console.log('--------------------------------------------------');
    console.log(`💬 WHATSAPP MESSAGE SENT TO: +91${phone}`);
    console.log(`📄 MESSAGE: \n${message}`);
    console.log('--------------------------------------------------');
    
    // Simulate API delay
    setTimeout(() => {
      resolve(true);
    }, 1000);
  });
};

module.exports = {
  sendWhatsAppMessage,
};
