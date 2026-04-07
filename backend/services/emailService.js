// const nodemailer = require('nodemailer');

// const transporter = nodemailer.createTransport({
//   service: 'gmail',
//   auth: {
//     user: process.env.EMAIL_USER,
//     pass: process.env.EMAIL_PASS,
//   },
// });

// exports.sendOtpEmail = async (email, otp) => {
//   const mailOptions = {
//     from: `"Gympilot Gym" <${process.env.EMAIL_USER}>`,
//     to: email,
//     subject: 'Your Verification OTP - Gympilot',
//     html: `
//       <div style="font-family: Arial, sans-serif; max-width: 600px; margin: auto; padding: 20px; border: 1px solid #ddd; border-radius: 10px;">
//         <h2 style="color: #F82F56; text-align: center;">Gympilot Gym Management</h2>
//         <p>Hello,</p>
//         <p>Your one-time password (OTP) for verification is:</p>
//         <div style="font-size: 24px; font-weight: bold; text-align: center; padding: 15px; background-color: #f9f9f9; border-radius: 5px; margin: 20px 0; color: #333; letter-spacing: 5px;">
//           ${otp}
//         </div>
//         <p>This OTP is valid for 10 minutes. Please do not share it with anyone.</p>
//         <p>If you did not request this, please ignore this email.</p>
//         <hr style="border: 0; border-top: 1px solid #eee; margin: 20px 0;">
//         <p style="font-size: 11px; color: #888; text-align: center;">&copy; 2026 Gympilot Gym Management System. All rights reserved.</p>
//       </div>
//     `,
//   };

//   try {
//     console.log('\n-----------------------------------');
//     console.log(`[VERIFICATION] OTP for ${email}: ${otp}`);
//     console.log('-----------------------------------\n');
//     await transporter.sendMail(mailOptions);
//     console.log(`OTP sent to ${email}`);
//   } catch (error) {
//     console.error('Error sending email:', error);
//     throw new Error('Failed to send verification email');
//   }
// };


const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

exports.sendOtpEmail = async (email, otp) => {
  const mailOptions = {
    from: `"Gympilot" <${process.env.EMAIL_USER}>`,
    to: email,
    subject: 'Your Verification OTP - Gympilot',
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: auto; padding: 20px; border: 1px solid #ddd; border-radius: 10px;">
        <h2 style="color: #F82F56; text-align: center;">Gympilot Application System</h2>
        <p>Hello,</p>
        <p>Your one-time password (OTP) for verification is:</p>
        <div style="font-size: 24px; font-weight: bold; text-align: center; padding: 15px; background-color: #f9f9f9; border-radius: 5px; margin: 20px 0; color: #333; letter-spacing: 5px;">
          ${otp}
        </div>
        <p>This OTP is valid for 10 minutes. Please do not share it with anyone.</p>
        <p>If you did not request this, please ignore this email.</p>
        <hr style="border: 0; border-top: 1px solid #eee; margin: 20px 0;">
        <p style="font-size: 11px; color: #888; text-align: center;">&copy; 2026  Gympilot Application System. All rights reserved.</p>
      </div>
    `,
  };

  try {
    console.log('\n-----------------------------------');
    console.log(`[VERIFICATION] OTP for ${email}: ${otp}`);
    console.log('-----------------------------------\n');
    await transporter.sendMail(mailOptions);
    console.log(`OTP sent to ${email}`);
    return true;
  } catch (error) {
    console.error('Error sending email:', error);
    return false;
  }
};