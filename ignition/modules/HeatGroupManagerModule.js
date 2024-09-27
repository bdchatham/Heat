const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

const HeatUserRegistryModule = require("./HeatUserRegistryModule");
const HeatSelectionManagerModule = require("./HeatSelectionManagerModule");

module.exports = buildModule("HeatGroupManagerModule", (m) => {

  const { userRegistry } = m.useModule(HeatUserRegistryModule);
  const { selectionManager } = m.useModule(HeatSelectionManagerModule);

  const groupManager = m.contract(
    "HeatGroupManager", 
    [3, 7, userRegistry, selectionManager], 
    {}
  );

  return { groupManager };
});
