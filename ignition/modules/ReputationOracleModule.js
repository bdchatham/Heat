const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("ReputationOracleModule", (m) => {

  const reputationOracle = m.contract("ReputationOracle", [m.getParameter("owner")], {});

  return { reputationOracle };
});
