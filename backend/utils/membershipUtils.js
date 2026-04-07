const getDaysByMonth = (months) => {
  const map = {
    1: 31, 2: 59, 3: 90, 4: 120, 5: 151, 6: 181,
    7: 212, 8: 243, 9: 273, 10: 304, 11: 334, 12: 365
  };
  return map[months] || (months * 30); // fallback
};

const calculateMemberStatus = (paymentDate, membershipDuration, membershipEndDate = null) => {
  if (!paymentDate && !membershipEndDate) return 'INACTIVE';

  const today = new Date();
  today.setHours(0, 0, 0, 0);

  let expiryDate;
  if (membershipEndDate) {
    expiryDate = new Date(membershipEndDate);
  } else {
    const start = new Date(paymentDate);
    const totalDays = getDaysByMonth(membershipDuration);
    expiryDate = new Date(start);
    expiryDate.setDate(start.getDate() + totalDays);
  }
  expiryDate.setHours(0, 0, 0, 0);

  const diffTime = expiryDate - today;
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

  if (diffDays >= 0) {
    if (diffDays <= 5) {
      return 'EXPIRING SOON';
    }
    return 'ACTIVE';
  } else if (diffDays < 0 && diffDays >= -10) {
    return 'OVERDUE';
  } else {
    return 'INACTIVE'; // Critically overdue (>10 days)
  }
};

const getMembershipDetails = (paymentDate, membershipDuration, membershipEndDate = null) => {
  const start = new Date(paymentDate);
  const totalDays = getDaysByMonth(membershipDuration);
  const expiryDate = membershipEndDate ? new Date(membershipEndDate) : new Date(start.getTime() + totalDays * 24 * 60 * 60 * 1000);

  return {
    startDate: start,
    expiryDate: expiryDate,
    status: calculateMemberStatus(paymentDate, membershipDuration, membershipEndDate)
  };
};

module.exports = {
  calculateMemberStatus,
  getMembershipDetails,
  getDaysByMonth
};
