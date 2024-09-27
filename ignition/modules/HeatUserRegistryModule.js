const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("HeatUserRegistryModule", (m) => {

  const userRegistry = m.contract("HeatUserRegistry", [], {});

  return { userRegistry };
});
