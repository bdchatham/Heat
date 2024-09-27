const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("VoteResultOracleModule", (m) => {

  const voteResultOracle = m.contract("VoteResultOracle", [m.getParameter("owner")], {});

  return { voteResultOracle };
});
