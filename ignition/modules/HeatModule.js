const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

const HeatSelectionManager = require("./HeatSelectionManagerModule");
const HeatGroupManager = require("./HeatGroupManagerModule");

module.exports = buildModule("HeatSelectionManagerModule", (m) => {

  m.useModule(HeatGroupManager);

  return {};
});
