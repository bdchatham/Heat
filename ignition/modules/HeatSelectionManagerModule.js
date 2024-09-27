const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

const VoteResultOracleModule = require("./VoteResultOracleModule");
const ReputationOracleModule = require("./ReputationOracleModule");

module.exports = buildModule("HeatSelectionManagerModule", (m) => {

  const { voteResultOracle } = m.useModule(VoteResultOracleModule);
  const { reputationOracle } = m.useModule(ReputationOracleModule);

  const selectionManager = m.contract(
    "HeatSelectionManager", 
    [m.getParameter("owner"), 
    voteResultOracle, 
    reputationOracle], 
    {}
  );

  return { selectionManager };
});
