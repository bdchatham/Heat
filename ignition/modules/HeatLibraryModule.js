const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("HeatLibraryModule", (m) => {

  const library = m.library("HeatLibrary");

  return { library };
});
