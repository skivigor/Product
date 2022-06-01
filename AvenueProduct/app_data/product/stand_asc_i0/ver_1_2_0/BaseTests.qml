import QtQuick 2.11
import "../../../tools/db_service.js" as JDbServ
import "../../ErrorCodes.js" as Codes

Item
{
    id: root

    QtObject
    {
        id: set
        property int stage: Codes.StageBasicInit
        // Thresholds
        property int thrMinV33: 3100
        property int thrMaxV33: 3500
        property int thrMinV39: 3600
        property int thrMaxV39: 4200
        property int thrMinV50: 4400 //4600
        property int thrMaxV50: 5300
        property int thrMinV20: 18000
        property int thrMaxV20: 22000
        property int thrMinV15: 13
        property int thrMaxV15: 16
        property int thrMinLuxMode0: 0
        property int thrMaxLuxMode0: 5
        property int thrMinLuxMode1: 4000
        property int thrMaxLuxMode1: 10000
        property int thrMinLuxMode2: 17000
        property int thrMaxLuxMode2: 21000
        property int thrMinLuxMode3: 20000
        property int thrMaxLuxMode3: 25000
        property int thrLoraFreq: 1000000
        property int thrLoraFreqDeviation: 10
        property int thrRtcFreq: 3276800
        property int thrRtcFreqDeviation: 200

        property int thrJccMinTemperature: 0
        property int thrJccMaxTemperature: 50

        property int jccDefaultConfigId: 0x00fb181b  // 13.08.21 by Vital  (0x00FB1A5B classID JCC not valid)
    }

    //-----------------------------------------------------------------

    function resetStand()
    {
        avlog.show("chocolate", "Reset stand ... Wait!", true, false)
        var ret = _standApiObj.resetStand()
        if (ret === false)
        {
            var code = Codes.CodeStandError
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, code, "Error: Reset Stand")
            avlog.show("red", code + ": ERROR: Reset Stand " + _name, false, true)
            return false
        }
        avlog.show("green", "Reset stand ... OK", false, false)
        return true
    }

    //-----------------------------------------------------------------

    function checkStatusVoltage33()
    {
        avlog.show("chocolate", "Check status of voltage 3.3 ... Wait!", true, false)

        var ret = _standApiObj.checkStatusVoltage33()
        if (ret === false)
        {
            var code = Codes.CodeStatusVolt33
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, code, "Error: status of voltage 3.3 V")
            avlog.show("red", code + ": ERROR: Check status of voltage 3.3 " + _name, false, true)
            return false
        }

        avlog.show("green", "Check status of voltage 3.3 ... OK", false, false)
        return true
    }

    //-----------------------------------------------------------------

    function setInputVoltage(inputVolt)
    {
        avlog.show("chocolate", "Set input voltage: " + inputVolt + "V ... Wait!", true, false)
        _power.loadOff()
        wait(500)
        _power.setVoltage(inputVolt)
        _power.loadOn()
        wait(5000)
        avlog.show("green", "Set input voltage: " + inputVolt + "V ... OK", false, false)
    }

    function checkValueVoltage33()
    {
        avlog.show("chocolate", "Check value of voltage 3.3 ... Wait!", true, false)

        var v33 = _standApiObj.checkValueVoltage33()
        if (v33 === false)
        {
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeStandError, "Error: Can not check value of voltage 3.3 V")
            avlog.show("red", Codes.CodeStandError + ": ERROR: Can not check value of voltage 3.3 " + _name, false, true)
            return false
        }

        if (v33 < set.thrMinV33 || v33 > set.thrMaxV33)
        {
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeValueVolt33, "Error: value of voltage 3.3 V: " + v33 + " mV out of range " + set.thrMinV33 + "-" + set.thrMaxV33)
            avlog.show("red", Codes.CodeValueVolt33 + ": ERROR: Check value of voltage 3.3: " + v33 + " mV", false, true)
            return false
        }

        avlog.show("green", "Check value of voltage 3.3 ... OK", false, false)
        return true
    }

    function checkValueVoltage39()
    {
        avlog.show("chocolate", "Check value of voltage 3.9 ... Wait!", true, false)

        var v50 = _standApiObj.checkValueVoltage50()
        if (v50 === false)
        {
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeStandError, "Error: value of voltage 3.9 V")
            avlog.show("red", Codes.CodeStandError + ": ERROR: Check value of voltage 3.9 " + _name, false, true)
            return false
        }

        if (v50 < set.thrMinV39 || v50 > set.thrMaxV39)
        {
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeValueVolt39, "Error: value of voltage 3.9 V: " + v50 + " mV out of range " + set.thrMinV39 + "-" + set.thrMaxV39)
            avlog.show("red", Codes.CodeValueVolt39 + ": ERROR: Check value of voltage 3.9: " + v50 + " mV", false, true)
            return false
        }

        avlog.show("green", "Check value of voltage 3.9 ... OK", false, false)
        return true
    }

    function checkValueVoltage50()
    {
        avlog.show("chocolate", "Check value of voltage 5.0 ... Wait!", true, false)

        var v50 = _standApiObj.checkValueVoltage50()
        if (v50 === false)
        {
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeStandError, "Error: value of voltage 5.0 V")
            avlog.show("red", Codes.CodeStandError + ": ERROR: Check value of voltage 5.0 " + _name, false, true)
            return false
        }

        if (v50 < set.thrMinV50 || v50 > set.thrMaxV50)
        {
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeValueVolt50, "Error: value of voltage 5.0 V: " + v50 + " mV out of range " + set.thrMinV50 + "-" + set.thrMaxV50)
            avlog.show("red", Codes.CodeValueVolt50 + ": ERROR: Check value of voltage 5.0: " + v50 + " mV", false, true)
            return false
        }

        avlog.show("green", "Check value of voltage 5.0 ... OK", false, false)
        return true
    }

    function checkValueVoltage20()
    {
        avlog.show("chocolate", "Check value of voltage 20.0 ... Wait!", true, false)

        var v20 = _standApiObj.checkValueVoltage20()
        if (v20 === false)
        {
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeStandError, "Error: get value of voltage 20.0 V")
            avlog.show("red", Codes.CodeStandError + ": ERROR: Get value of voltage 20.0 " + _name, false, true)
            return false
        }
        console.log("Check voltage 20V: " + v20)

        if (v20 < set.thrMinV20 || v20 > set.thrMaxV20)
        {
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeValueVolt20, "Error: value of voltage 20.0 V: " + v20 + " mV out of range " + set.thrMinV20 + "-" + set.thrMaxV20)
            avlog.show("red", Codes.CodeValueVolt20 + ": ERROR: Check value of voltage 20.0: " + v20 + " mV", false, true)
            return false
        }

        avlog.show("green", "Check value of voltage 20.0 ... OK", false, false)
        return true
    }

    function checkValueVoltage15()
    {
        avlog.show("chocolate", "Check value of voltage 15 V ... Wait!", true, false)

        var v15 = _fwApi.getBatSensorLevel()
        if (v15 === false)
        {
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeStandError, "Error: value of voltage 15 V")
            avlog.show("red", Codes.CodeStandError + ": ERROR: Check value of voltage 15 V " + _name, false, true)
            return false
        }

        if (v15 < set.thrMinV15 || v15 > set.thrMaxV15)
        {
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeValueVolt15, "Error: value of voltage 15 V: " + v15 + " V out of range " + set.thrMinV15 + "-" + set.thrMaxV15)
            avlog.show("red", Codes.CodeValueVolt15 + ": ERROR: Check value of voltage 15 V: " + v15 + " V", false, true)
            return false
        }

        avlog.show("green", "Check value of voltage 15 V ... OK", false, false)
        return true
    }

    //-----------------------------------------------------------------

    function checkLightSensor()
    {
        avlog.show("chocolate", "Check light sensor: mode 1 ... Wait!", true, false)
        var ret = checkLightSensorLevel(1, set.thrMinLuxMode1, set.thrMaxLuxMode1)
        if (ret === false) return false

        //            avlog.show("chocolate", "Check light sensor: mode 2 ... Wait!", true, false)
        //            ret = checkLightSensorLevel(2, set.thrMinLuxMode2, set.thrMaxLuxMode2)
        //            if (ret === false) return false

        //            avlog.show("chocolate", "Check light sensor: mode 3 ... Wait!", true, false)
        //            ret = checkLightSensorLevel(3, set.thrMinLuxMode3, set.thrMaxLuxMode3)
        //            if (ret === false) return false

        avlog.show("chocolate", "Check light sensor: mode 0 ... Wait!", true, false)
        ret = checkLightSensorLevel(0, set.thrMinLuxMode0, set.thrMaxLuxMode0)
        if (ret === false) return false

        avlog.show("green", "Check light sensor ... OK", false, false)
        return true
    }

    function checkLightSensorLevel(mode, min, max)
    {
        if (mode > 3 || min > max) return false

        // Set Light mode
        var ret = _standApiObj.setLightMode(mode)
        if (ret === false)
        {
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeStandError, "Error: Set light mode: " + mode)
            avlog.show("red", Codes.CodeStandError + ": ERROR: Set light mode: " + mode, false, true)
            return false
        }
        wait(4000)

        // Get Light level
        var lvl = _fwApi.getLsLightLevel(1)
        if (lvl === false)
        {
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeBoardError, "Error: get light level")
            avlog.show("red", Codes.CodeBoardError + ": ERROR: Get light level", false, true)
            return false
        }

        console.log("LightSensor level: " + lvl)
        if (lvl < min || lvl > max)
        {
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeLightSensor, "Error: light level: " + lvl + " lux out of range " + min + "-" + max)
            avlog.show("red", Codes.CodeLightSensor + ": ERROR: Get light level: " + lvl + " lux out of range " + min + "-" + max, false, true)
            return false
        }

        return true
    }

    //-----------------------------------------------------------------

    function checkPwmLevel()
    {
        avlog.show("chocolate", "Check PWM level ... Wait!", true, false)

        // Switch ON all ENA
        var ret = _fwApi.switchLmEnaOn()
        if (ret === false)
        {
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeBoardError, "Error: Switch ON all ENA")
            avlog.show("red", Codes.CodeBoardError + ": ERROR: Switch ON all ENA " + _name, false, true)
            return false
        }

        // Check channels
        // Level 95%
        ret = checkPwmLevelChannels(95)
        if (ret === false) return false

        // Level 50%
        ret = checkPwmLevelChannels(50)
        if (ret === false) return false

        // Level 10%
        ret = checkPwmLevelChannels(10)
        if (ret === false) return false

        avlog.show("green", "Check PWM level ... OK", false, false)
        return true
    }

    function checkPwmLevelChannels(val)
    {
        avlog.show("chocolate", "Check PWM level " + val + "% ... Wait!", true, false)

        // Set PWM level
        var ret = _fwApi.setLactPwmLevel(val)
        if (ret === false)
        {
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeBoardError, "Error: Set PWM level " + val)
            avlog.show("red", Codes.CodeBoardError + ": Error: Set PWM level " + val + " " + _name, false, true)
            return false
        }
        wait(50)
        // Read PWM channels
        for (var i = 0; i < 5; ++i)
        {
            // getPwmLevel
            var lvl = _standApiObj.getPwmLevel(i)
            if (lvl === false)
            {
                JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeStandError, "Error: Read PWM level on " + i + " channel")
                avlog.show("red", Codes.CodeStandError + ": ERROR: Read PWM level on " + i + " channel " + _name, false, true)
                return false
            }

            console.log("PWM at " + val + "% : " + lvl)
            if (lvl < val - 2 || lvl > val + 2)
            {
                JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodePwmLevel, "Error: PWM level " + val)
                avlog.show("red", Codes.CodePwmLevel + ": ERROR: PWM level " + val + " " + _name, false, true)
                return false
            }
        }
        return true
    }

    //-----------------------------------------------------------------

    function checkLoraOscillatorFreq()
    {
        avlog.show("chocolate", "Check Crystal Oscillator of transceiver ... Wait!", true, false)

        // Set Test Mode on board
        var ret = _fwApi.enableLoraTestMode()
        if (ret === false)
        {
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeBoardError, "Error: Set Test Mode for Lora")
            avlog.show("red", Codes.CodeBoardError + ": ERROR: Set Test Mode for Lora " + _name, false, true)
            return false
        }

        wait(100)

        // Check Crystal Oscillator freq
        var freq = _standApiObj.getLoraOscillatorFreq()
        if (freq === false)
        {
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeStandError, "Error: Get Crystal Oscillator frequency")
            avlog.show("red", Codes.CodeStandError + ": ERROR: Get Crystal Oscillator frequency " + _name, false, true)
            return false
        }
        console.log("Crystal Oscillator of transceiver freq: " + freq)
        if (freq < (set.thrLoraFreq - set.thrLoraFreqDeviation) || freq > (set.thrLoraFreq + set.thrLoraFreqDeviation))
        {
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeLoraOscillatorFreq, "Error: Crystal Oscillator frequency " + freq)
            avlog.show("red", Codes.CodeLoraOscillatorFreq + ": ERROR: Crystal Oscillator frequency " + freq + " " + _name, false, true)
            return false
        }

        avlog.show("green", "Check Crystal Oscillator of transceiver ... OK", false, false)
        return true
    }

    //-----------------------------------------------------------------

    function checkSurgeProtection()
    {
        avlog.show("chocolate", "Check Surge Protection ... Wait!", true, false)

        // Enable Protection
        var ret = _standApiObj.enableProtection()
        if (ret === false)
        {
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeStandError, "Error: Enable Protection")
            avlog.show("red", Codes.CodeStandError + ": ERROR: Enable Protection " + _name, false, true)
            return false
        }

        //        wait(1000)

        // Check Protection on Board
        var sp = _fwApi.getLmProtectionStatus()
        if (sp === false)
        {
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeBoardError, "Error: Get Protection status")
            avlog.show("red", Codes.CodeBoardError + ": ERROR: Get Protection status " + _name, false, true)
            return false
        }

        if (sp !== 0)
        {
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeSurgeProtection, "Error: Protection not working")
            avlog.show("red", Codes.CodeSurgeProtection + ": ERROR: Protection not working " + _name, false, true)
            return false
        }

        // Disable Protection
        ret = _standApiObj.disableProtection()
        if (ret === false)
        {
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeStandError, "Error: Disable Protection")
            avlog.show("red", Codes.CodeStandError + ": ERROR: Disable Protection " + _name, false, true)
            return false
        }

        //        wait(1000)

        // Check Protection on Board
        sp = _fwApi.getLmProtectionStatus()
        if (sp === false)
        {
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeBoardError, "Error: Get Protection status")
            avlog.show("red", Codes.CodeBoardError + ": ERROR: Get Protection status " + _name, false, true)
            return false
        }

        if (sp !== 1)
        {
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeSurgeProtection, "Error: Protection not working")
            avlog.show("red", Codes.CodeSurgeProtection + ": ERROR: Protection not working " + _name, false, true)
            return false
        }

        avlog.show("green", "Check Surge Protection ... OK", false, false)
        return true
    }

    //-----------------------------------------------------------------

    function emWifiSleep()
    {
        var ret = _fwApi.wifiEnableSleepMode()
        if (ret === false)
        {
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeBoardError, "Error: Can not sleep WiFi module")
            avlog.show("red", Codes.CodeBoardError + ": ERROR: Can not sleep WiFi module " + _name, false, true)
            return false
        }

        ret = _fwApi.wifiSleep()
        if (ret === false)
        {
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeBoardError, "Error: Can not sleep WiFi module")
            avlog.show("red", Codes.CodeBoardError + ": ERROR: Can not sleep WiFi module " + _name, false, true)
            return false
        }

        return true
    }

    function emWifiWakeup()
    {
        return _fwApi.wifiWakeup()
    }

    function emStandRelay(state)
    {
        var ret = _standApiObj.setLoadRelay(state)
        if (ret === false)
        {
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeStandError, "Error: Switch stand relay")
            avlog.show("red", Codes.CodeStandError + ": ERROR: Switch stand relay " + _name, false, true)
            return false
        }

        return true
    }

    function emLampRelay(state)
    {
        var ret = _fwApi.setLactSwitch(state)
        if (ret === false)
        {
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeBoardError, "Error: Switch lamp relay")
            avlog.show("red", Codes.CodeBoardError + ": ERROR: Switch lamp relay " + _name, false, true)
            return false
        }

        return true
    }

    function emLampPwmLevel(level)
    {
        var ret = _fwApi.setLactPwmLevel(level)
        if (ret === false)
        {
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeBoardError, "Error: Set PWM level " + level)
            avlog.show("red", Codes.CodeBoardError + ": ERROR: Set PWM level " + level + " " + _name, false, true)
            return false
        }

        return true
    }

    function emPowerMeterMeasurement()
    {
        wait(1000)
        var pw, pfactor, rms = 0
        for (var i = 0; i < 10; ++i)
        {
            wait(1000)
            pw = _power.getMeasPower()
            if (pw <= 0.1)
            {
                JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeExtPowerSupply, "Error: External Power Supply")
                avlog.show("red", Codes.CodeExtPowerSupply + ": ERROR: External Power Supply " + _name, false, true)
                return false
            }
            pfactor = _power.getMeasPFactor()
            rms += pw
            console.log("POWER: " + pw + " " + pfactor)
        }
        console.log("RMS POWER: " + rms / 10)
        return rms / 10
    }   // emPowerMeterMeasurement

    function emPowerMeterMeasurementQuick()
    {
        wait(1000)
        var pw, pfactor, rms = 0
        for (var i = 0; i < 10; ++i)
        {
            wait(1000)
            pw = _power.getMeasPower()
            if (pw <= 0.1)
            {
                JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeExtPowerSupply, "Error: External Power Supply")
                avlog.show("red", Codes.CodeExtPowerSupply + ": ERROR: External Power Supply " + _name, false, true)
                return false
            }
            pfactor = _power.getMeasPFactor()
            rms += pw
            console.log("POWER: " + pw + " " + pfactor)
        }
        console.log("RMS POWER: " + rms / 10)
        return rms / 10
    }   // emPowerMeterMeasurement

    function emLampMeasurement()
    {
        var empw = _fwApi.getEmPowerMeas()
        if (empw === false)
        {
            avlog.show("red", "ERROR!!! Error: Read lamp EM " + _name, false, true)
            return false
        }

        console.log("EM POWER: " + empw)
        return empw
    }

    function emSetCalibrationData(val)
    {
        var ret = _fwApi.setEmCalibrationData(val)
        if (ret === false)
        {
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeBoardError, "Error: Set Calibration data to EM")
            avlog.show("red", Codes.CodeBoardError + ": ERROR: Set Calibration data to EM " + _name, false, true)
            return false
        }

        return true
    }

    function emLampStatus()
    {
        //
    }

    function checkEmCalibration()
    {
        avlog.show("chocolate", "Electrical Meter calibration ... Wait!", true, false)
        var lvl = 0   // pwm level, %
        var i = 0
        var cmd, resp, rms
        var ret = false

        // Enable Protection
        //        ret = _standApiObj.enableProtection()
        //        if (ret === false)
        //        {
        //            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, 401, "Error: Enable Protection")
        //            avlog.show("red", "ERROR!!! Enable Protection " + _name, false, true)
        //            return false
        //        }

        // Sleep Wifi
        ret = emWifiSleep()
        if (ret === false) return false

        // Reset EM calibration parameters
        if (_emCalibrateEnabled)
        {
            // resetEmCalibrationData
            console.log("Reset EM calibration factor")
            ret = _fwApi.resetEmCalibrationData()
            if (ret === false)
            {
                JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeBoardError, "Error: Reset EM calibration")
                avlog.show("red", Codes.CodeBoardError + ": ERROR: Reset EM calibration " + _name, false, true)
                return false
            }
        }

        // Set PWM level 0 %
        ret = emLampPwmLevel(0)
        if (ret === false) return false

        // Switch OFF lamp relay
        ret = emLampRelay(false)
        if (ret === false) return false

        //        // Switch ON stand relay
        //        ret = emStandRelay(true)
        //        if (ret === false) return false

        console.log("-------------------------------------")
        rms = emPowerMeterMeasurement()
        //        console.log("!!! RMS: " + rms)

        // Check sleep mode
        if (rms > 1.4)
        {
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeEspSleepMode, "Error: ESP sleep mode")
            avlog.show("red", Codes.CodeEspSleepMode + ": ERROR: ESP sleep mode : " + _name, false, true)
            return false
        }

        // Check board electric meter
        var volt = _fwApi.getEmVoltageMeas()
        if (volt < 200 || volt > 240)
        {
            console.log("Check board EM voltage: " + volt + "V")
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeEmMetering, "Error: Check board EM voltage: " + volt + "V")
            avlog.show("red", Codes.CodeEmMetering + ": ERROR: Check board EM voltage: " + volt + "V : " + _name, false, true)
            return false
        }
        console.log("Check board EM voltage: " + volt + "V")

        // Get Lamp PW
        if (!_emCalibrateEnabled)
        {
            ret = emLampMeasurement()
            if (ret === false) return false
        }

        // Set calibration data
        if (_emCalibrateEnabled)
        {
            ret = emSetCalibrationData(rms)
            if (ret === false) return false
        }

        // Set PWM level 100 %
        ret = emLampPwmLevel(100)
        if (ret === false) return false

        // Switch ON stand relay
        ret = emStandRelay(true)
        if (ret === false) return false
        wait(1000)

        // Switch ON lamp relay
        ret = emLampRelay(true)
        if (ret === false) return false

        rms = emPowerMeterMeasurement()
        //        console.log("!!! RMS: " + rms)
        // Check board load relay
        if (rms < 40)
        {
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeBoardRelay, "Error: Board load relay")
            avlog.show("red", Codes.CodeBoardRelay + ": ERROR: Board load relay : " + _name, false, true)
            return false
        }

        // Get Lamp PW
        if (!_emCalibrateEnabled)
        {
            ret = emLampMeasurement()
            if (ret === false) return false
        }

        // Set calibration data
        if (_emCalibrateEnabled)
        {
            ret = emSetCalibrationData(rms)
            if (ret === false) return false
        }

        // CheckCalibration High level
        if (_emCalibrateEnabled)
        {
            avlog.show("chocolate", "Electrical Meter check High level ... Wait!", true, false)
            console.log("Check board EM calibration High level")
            wait(1000)
            rms = emPowerMeterMeasurement()
            var empw = emLampMeasurement()
            if ((empw > rms + 0.7) || empw < rms - 0.7)
            {
                JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeEmCalibration, "Error: EM calibration PS/EM: " + rms.toFixed(2) + "/" + empw + " Wt")
                avlog.show("red", Codes.CodeEmCalibration + ": ERROR: EM calibration PS/EM: " + rms.toFixed(2) + "/" + empw + " Wt : " + _name, false, true)
                return false
            }
        }

        // Switch OFF stand relay
        ret = emStandRelay(false)
        if (ret === false) return false

        // Set PWM level 0 %
        ret = emLampPwmLevel(0)
        if (ret === false) return false

        // Switch OFF lamp relay
        ret = emLampRelay(false)
        if (ret === false) return false

        // CheckCalibration Low level
        if (_emCalibrateEnabled)
        {
            avlog.show("chocolate", "Electrical Meter check Low level ... Wait!", true, false)
            console.log("Check board EM calibration Low level")
            wait(1000)
            rms = emPowerMeterMeasurement()
            empw = emLampMeasurement()
            if ((empw > rms + 0.3) || empw < rms - 0.3)
            {
                JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeEmCalibration, "Error: EM calibration PS/EM: " + rms.toFixed(2) + "/" + empw + " Wt")
                avlog.show("red", Codes.CodeEmCalibration + "ERROR: EM calibration PS/EM: " + rms.toFixed(2) + "/" + empw + " Wt : " + _name, false, true)
                return false
            }
        }


        // Disable Protection
        //        ret = _standApiObj.disableProtection()
        //        if (ret === false)
        //        {
        //            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, 401, "Error: Disable Protection")
        //            avlog.show("red", "ERROR!!! Disable Protection " + _name, false, true)
        //            return false
        //        }

        // Wifi wakeup
        emWifiWakeup()

        avlog.show("green", "Electrical Meter calibration ... OK", false, false)
        return true
    }   // emCalibration

    function checkEmCalibrationQuick()
    {
        avlog.show("chocolate", "Electrical Meter calibration ... Wait!", true, false)
        var lvl = 0   // pwm level, %
        var i = 0
        var cmd, resp, rms
        var ret = false

//        // Sleep Wifi
//        ret = emWifiSleep()
//        if (ret === false) return false

        // Reset EM calibration parameters
        if (_emCalibrateEnabled)
        {
            // resetEmCalibrationData
            console.log("Reset EM calibration factor")
            ret = _fwApi.resetEmCalibrationData()
            if (ret === false)
            {
                JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeBoardError, "Error: Reset EM calibration")
                avlog.show("red", Codes.CodeBoardError + ": ERROR: Reset EM calibration " + _name, false, true)
                return false
            }
        }

        // Set PWM level 0 %
        ret = emLampPwmLevel(0)
        if (ret === false) return false

        // Switch OFF lamp relay
        ret = emLampRelay(false)
        if (ret === false) return false

        console.log("-------------------------------------")
        rms = emPowerMeterMeasurementQuick()
        //        console.log("!!! RMS: " + rms)

        // Check sleep mode
//        if (rms > 1.4)
//        {
//            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeEspSleepMode, "Error: ESP sleep mode")
//            avlog.show("red", Codes.CodeEspSleepMode + ": ERROR: ESP sleep mode : " + _name, false, true)
//            return false
//        }

        // Check board electric meter
        var volt = _fwApi.getEmVoltageMeas()
        if (volt < 200 || volt > 240)
        {
            console.log("Check board EM voltage: " + volt + "V")
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeEmMetering, "Error: Check board EM voltage: " + volt + "V")
            avlog.show("red", Codes.CodeEmMetering + ": ERROR: Check board EM voltage: " + volt + "V : " + _name, false, true)
            return false
        }
        console.log("Check board EM voltage: " + volt + "V")

        // Get Lamp PW
        if (!_emCalibrateEnabled)
        {
            ret = emLampMeasurement()
            if (ret === false) return false
        }

        // Set calibration data
        if (_emCalibrateEnabled)
        {
            ret = emSetCalibrationData(rms)
            if (ret === false) return false
        }

        // Set PWM level 100 %
        ret = emLampPwmLevel(100)
        if (ret === false) return false

        // Switch ON stand relay
        ret = emStandRelay(true)
        if (ret === false) return false
        wait(1000)

        // Switch ON lamp relay
        ret = emLampRelay(true)
        if (ret === false) return false

        rms = emPowerMeterMeasurementQuick()
        //        console.log("!!! RMS: " + rms)
        // Check board load relay
        if (rms < 40)
        {
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeBoardRelay, "Error: Board load relay")
            avlog.show("red", Codes.CodeBoardRelay + ": ERROR: Board load relay : " + _name, false, true)
            return false
        }

        // Get Lamp PW
        if (!_emCalibrateEnabled)
        {
            ret = emLampMeasurement()
            if (ret === false) return false
        }

        // Set calibration data
        if (_emCalibrateEnabled)
        {
            ret = emSetCalibrationData(rms)
            if (ret === false) return false
        }

        // CheckCalibration High level
        if (_emCalibrateEnabled)
        {
            avlog.show("chocolate", "Electrical Meter check High level ... Wait!", true, false)
            console.log("Check board EM calibration High level")
            wait(1000)
            rms = emPowerMeterMeasurementQuick()
            var empw = emLampMeasurement()
            if ((empw > rms + 0.7) || empw < rms - 0.7)
            {
                JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeEmCalibration, "Error: EM calibration PS/EM: " + rms.toFixed(2) + "/" + empw + " Wt")
                avlog.show("red", Codes.CodeEmCalibration + ": ERROR: EM calibration PS/EM: " + rms.toFixed(2) + "/" + empw + " Wt : " + _name, false, true)
                return false
            }
        }

        // Switch OFF stand relay
        ret = emStandRelay(false)
        if (ret === false) return false

        // Set PWM level 0 %
        ret = emLampPwmLevel(0)
        if (ret === false) return false

        // Switch OFF lamp relay
        ret = emLampRelay(false)
        if (ret === false) return false

        // CheckCalibration Low level
        if (_emCalibrateEnabled)
        {
            avlog.show("chocolate", "Electrical Meter check Low level ... Wait!", true, false)
            console.log("Check board EM calibration Low level")
            wait(1000)
            rms = emPowerMeterMeasurementQuick()
            empw = emLampMeasurement()
            if ((empw > rms + 0.3) || empw < rms - 0.3)
            {
                JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeEmCalibration, "Error: EM calibration PS/EM: " + rms.toFixed(2) + "/" + empw + " Wt")
                avlog.show("red", Codes.CodeEmCalibration + "ERROR: EM calibration PS/EM: " + rms.toFixed(2) + "/" + empw + " Wt : " + _name, false, true)
                return false
            }
        }

        // Wifi wakeup
//        emWifiWakeup()

        avlog.show("green", "Electrical Meter calibration ... OK", false, false)
        return true
    }   // emCalibration


    function checkEm()
    {
        avlog.show("chocolate", "Electrical Meter check ... Wait!", true, false)
        var lvl = 0   // pwm level, %
        var i = 0
        var cmd, resp, rms
        var ret = false

        // resetEmCalibrationData
        console.log("Reset EM calibration factor")
        ret = _fwApi.resetEmCalibrationData()
        if (ret === false)
        {
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeBoardError, "Error: Reset EM calibration")
            avlog.show("red", Codes.CodeBoardError + ": ERROR: Reset EM calibration " + _name, false, true)
            return false
        }

        // Set PWM level 100 %
        ret = emLampPwmLevel(100)
        if (ret === false) return false

        // Switch ON stand relay
        ret = emStandRelay(true)
        if (ret === false) return false
        wait(1000)

        // Switch ON lamp relay
        ret = emLampRelay(true)
        if (ret === false) return false

        console.log("Check board EM at High level")
        wait(15000)

        // Check board electric meter
        var volt = _fwApi.getEmVoltageMeas()
        if (volt < 200 || volt > 240)
        {
            console.log("Check board EM voltage: " + volt + "V")
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeEmMetering, "Error: Check board EM voltage: " + volt + "V")
            avlog.show("red", Codes.CodeEmMetering + ": ERROR: Check board EM voltage: " + volt + "V : " + _name, false, true)
            return false
        }
        console.log("Check board EM voltage: " + volt + "V")

        var empw = emLampMeasurement()
        if ((empw > 73) || empw < 67)
        {
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeEmMetering, "Error: EM measurement: " + empw + " Wt")
            avlog.show("red", Codes.CodeEmMetering + ": ERROR: EM measurement: " + empw + " Wt : " + _name, false, true)
            return false
        }

        // Switch OFF stand relay
        ret = emStandRelay(false)
        if (ret === false) return false

        avlog.show("green", "Electrical Meter check ... OK", false, false)
        return true
    }


    //-----------------------------------------------------------------

    function crashEmCalibration()
    {
        avlog.show("black", "Electrical Meter crash ... Wait!", true, false)
        var lvl = 0   // pwm level, %
        var i = 0
        var cmd, resp, rms
        var ret = false

        // Sleep Wifi
        ret = emWifiSleep()
        if (ret === false) return false

        _fwApi.resetEmCalibrationData()

        // Set PWM level 0 %
        ret = emLampPwmLevel(0)
        if (ret === false) return false

        // Switch OFF lamp relay
        ret = emLampRelay(false)
        if (ret === false) return false

        wait(12000)

        console.log("!!!!! Crash EM at Low level")

        // Set calibration data
        if (_emCalibrateEnabled)
        {
            ret = emSetCalibrationData(300)
            if (ret === false) return false
        }

        // Set PWM level 100 %
        ret = emLampPwmLevel(100)
        if (ret === false) return false

        // Switch ON stand relay
        ret = emStandRelay(true)
        if (ret === false) return false
        wait(1000)

        // Switch ON lamp relay
        ret = emLampRelay(true)
        if (ret === false) return false

        wait(12000)

        console.log("!!!!! Crash EM at High level")

        // Set calibration data
        if (_emCalibrateEnabled)
        {
            ret = emSetCalibrationData(77)
            if (ret === false) return false
        }

        // Switch OFF stand relay
        ret = emStandRelay(false)
        if (ret === false) return false

        // Wifi wakeup
        emWifiWakeup()

        avlog.show("black", "Electrical Meter crash ... OK", false, false)
        return true
    }

    function checkEmCrash()
    {
        avlog.show("chocolate", "Electrical Meter crash check ... Wait!", true, false)
        var lvl = 0   // pwm level, %
        var i = 0
        var cmd, resp, rms
        var ret = false

        // Sleep Wifi
        ret = emWifiSleep()
        if (ret === false) return false

        // Set PWM level 100 %
        ret = emLampPwmLevel(100)
        if (ret === false) return false

        // Switch ON stand relay
        ret = emStandRelay(true)
        if (ret === false) return false
        wait(1000)

        // Switch ON lamp relay
        ret = emLampRelay(true)
        if (ret === false) return false

        // CheckCalibration High level
        if (_emCalibrateEnabled)
        {
            wait(1000)
            rms = emPowerMeterMeasurement()
            var empw = emLampMeasurement()
        }

        // Switch OFF stand relay
        ret = emStandRelay(false)
        if (ret === false) return false

        // Set PWM level 0 %
        ret = emLampPwmLevel(0)
        if (ret === false) return false

        // Switch OFF lamp relay
        ret = emLampRelay(false)
        if (ret === false) return false

        // CheckCalibration Low level
        if (_emCalibrateEnabled)
        {
            wait(1000)
            rms = emPowerMeterMeasurement()
            empw = emLampMeasurement()
        }

        // Wifi wakeup
        emWifiWakeup()

        return true
    }

    //-----------------------------------------------------------------

    function setDeviceInfo()
    {
        avlog.show("chocolate", "Set device information ... Wait!", true, false)

        // Set Serial, HwType, HwVersion
        var req = {}
        req.req = "getHwTypeAttrByBoardKt"
        req.args = [_objDevice.frefkt]
        var resp = JSON.parse(JDbServ.sendDbRequest(_dbClient, req))
        if (resp["error"] === true)
        {
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeDatabaseError, "Error Get HwType info")
            avlog.show("red", Codes.CodeDatabaseError + ": Get HwType info ... Error!!!", false, true)
            return false
        }

        var data = resp["data"]
        if (data.length === 0)
        {
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeDatabaseError, "HwType info not found")
            avlog.show("red", Codes.CodeDatabaseError + ": HwType info not found: " + res + " Error!!!", false, true)
            return false
        }

        var serial = util.createSerialNumber(_objDevice.fdeviceid)
        var hwType = util.intToArray(data[0]["fhwtypeid"], 2)
        var hwVer = util.createHwVersion(data[0]["fboardcurrentversion"])

        console.log("!!!!! Serial: " + serial)
        console.log("!!!!! hwType: " + hwType)
        console.log("!!!!! hwVer: " + hwVer)

        var ret = _fwApi.setBasicDevInfo(serial, hwType, hwVer)
        if (ret === false)
        {
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeBoardError, "Error set device info")
            avlog.show("red", Codes.CodeBoardError + ": ERROR: Set DevInfo settings " + _name, false, true)
            return false
        }

        avlog.show("green", "Set device information ... OK", false, false)
        return true
    }

    //-----------------------------------------------------------------

    function setBaseParameters()
    {
        avlog.show("chocolate", "Set Base Parameters ... Wait!", true, false)

        // Set UTC time
        var ret = _fwApi.setTimeUtc()
        if (ret === false)
        {
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeBoardNotStarted, "Error set Time")
            avlog.show("red", Codes.CodeBoardNotStarted + ": ERROR: Set Time " + _name, false, true)
            return false
        }

        // Set TZ/DLS
        ret = _fwApi.setTimeTzDls()
        if (ret === false)
        {
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeBoardError, "Error set TZ/DLS")
            avlog.show("red", Codes.CodeBoardError + ": ERROR: Set TZ/DLS " + _name, false, true)
            return false
        }

        // Reset all data collections
        ret = _fwApi.resetDCollSettings()
        if (ret === false)
        {
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeBoardError, "Error DColl reset")
            avlog.show("red", Codes.CodeBoardError + ": ERROR: DColl reset " + _name, false, true)
            return false
        }

        avlog.show("green", "Set Base Parameters ... OK", false, false)
        return true
    }

    //-----------------------------------------------------------------

    function enableProductionScope()
    {
        avlog.show("chocolate", "Enable production scope ... Wait!", true, false)
        // enableProductScope
        var ret = _fwApi.enableProductScope()
        if (ret === false)
        {

            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeEnableProductScope, "Error enable production scope")
            avlog.show("red", Codes.CodeEnableProductScope + ": ERROR: Enable production scope " + _name, false, true)
            return false
        }

        avlog.show("green", "Enable production scope ... OK", false, false)
        return true
    }

    //-----------------------------------------------------------------

    function jcc_checkStart()
    {
        avlog.show("chocolate", "Check JCC start ... Wait!", true, false)
        // enableProductScope
        var ret = _fwApi.getClassId()
        if (ret === false)
        {

            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeBoardNotStarted, "Error JCC start")
            avlog.show("red", Codes.CodeBoardNotStarted + ": ERROR: JCC start " + _name, false, true)
            return false
        }
        console.log("!!!!!! Default class ID: 0x" + set.jccDefaultConfigId.toString(16) + "  On board: 0x" + ret.toString(16))

        if (ret !== set.jccDefaultConfigId)
        {
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeBoardClassIdError, "Error JCC class ID")
            avlog.show("red", Codes.CodeBoardClassIdError + ": ERROR: JCC class ID " + _name, false, true)
            return false
        }

        avlog.show("green", "JCC start ... OK", false, false)
        return true
    }

    //-----------------------------------------------------------------

    function jcc_internalDiagnostic()
    {
        avlog.show("chocolate", "JCC internal diagnostic ... Wait!", true, false)

        var count = 0
        var ret = {}

        do
        {
            ret = _fwApi.jcc_getInternalStatus()
            if (ret === false)
            {

                JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeBoardError, "Error JCC internal diagnostic")
                avlog.show("red", Codes.CodeBoardError + ": ERROR: JCC internal diagnostic " + _name, false, true)
                return false
            }
            count++
            wait(2000)
        } while ((ret.eeprom !== true || ret.dataFlash !== true || ret.rtc !== true || ret.gsm !== true) && count < 20)

        console.log("Internal status: " + JSON.stringify(ret))

        if (ret.eeprom === false)
        {

            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeJccEeprom, "Error JCC EEPROM")
            avlog.show("red", Codes.CodeJccEeprom + ": ERROR: JCC EEPROM " + _name, false, true)
            return false
        }

        if (ret.dataFlash === false)
        {

            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeJccDataFlash, "Error JCC Data Flash")
            avlog.show("red", Codes.CodeJccDataFlash + ": ERROR: JCC Data Flash " + _name, false, true)
            return false
        }

        if (ret.rtc === false)
        {

            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeJccRtc, "Error JCC RTC")
            avlog.show("red", Codes.CodeJccRtc + ": ERROR: JCC RTC " + _name, false, true)
            return false
        }

        if (ret.gsm === false)
        {

            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeJccGsm, "Error JCC GSM modem")
            avlog.show("red", Codes.CodeJccGsm + ": ERROR: JCC GSM modem " + _name, false, true)
            return false
        }

        if (ret.temp < set.thrJccMinTemperature || ret.temp > set.thrJccMaxTemperature)
        {
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], set.stage, Codes.CodeJccTempSensor, "Error JCC Temperature sensor")
            avlog.show("red", Codes.CodeJccTempSensor + ": ERROR: JCC Temperature sensor " + _name, false, true)
            return false
        }

        avlog.show("green", "JCC internal diagnostic ... OK", false, false)
        return true
    }

}


















