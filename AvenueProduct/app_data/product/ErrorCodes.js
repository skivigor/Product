.pragma library

// Stages codes
var StageBasicInit = 100
var StageAssembly  = 101
var StageVendor    = 102
var StageLampType  = 103
var StageWifi      = 104
var StageLora      = 105
var StageFinish    = 999

// Board codes
var CodeFirmwareError = 200   // global error
var CodeFirmwareEsp   = 201
var CodeFirmwareStm   = 202

var CodeBoardNotStarted    = 210
var CodeBoardClassIdError  = 211
var CodeStatusVolt33       = 220
var CodeValueVolt33        = 221
var CodeValueVolt50        = 222
var CodeValueVolt39        = 223
var CodeValueVolt15        = 224
var CodeValueVolt20        = 225
var CodeLoraOscillatorFreq = 230
var CodeLightSensor        = 231
var CodePwmLevel           = 232
var CodeSurgeProtection    = 233
var CodeEmMetering         = 234
var CodeEmCalibration      = 235
var CodeBoardRelay         = 236
var CodeEspSleepMode       = 237
var CodeJccLeds            = 238
var CodeJccEeprom          = 239
var CodeJccDataFlash       = 240
var CodeJccRtc             = 241
var CodeJccGsm             = 242
var CodeJccTempSensor      = 243

// Driver codes
var CodeDrvPowerFactor      = 300
var CodeDrvPower            = 301
var CodeDrvInputCurrent220  = 302
var CodeDrvInputCurrent120  = 303
var CodeDrvInputCurrent280  = 304
var CodeDrvOutputCurrent220 = 305
var CodeDrvOutputCurrent120 = 306
var CodeDrvOutputCurrent280 = 307
var CodeDrvCtrlVoltage      = 308
var CodeDrvHighVoltage      = 309
var CodeDrvOutputCurrent10  = 310
var CodeDrvOutputCurrent0   = 311
var CodeDrvNoLoadCurrent    = 312

// Software codes
var CodeOk            = 0
var CodeStandError         = 400
var CodeBoardError         = 401
var CodeDatabaseError      = 402
var CodeExtPowerSupply     = 403
var CodeEnableProductScope = 404






