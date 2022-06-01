import QtQuick 2.11
import "../ErrorCodes.js" as Codes

Item
{
    id: root

    property int _measTimeout: 2000

    //-----------------------------------------------------------------
    // Check input/output current
    function stage1(args)
    {
        avlog.show("chocolate", "Input/Output current measurement ... Running!", true, false)

        var Iout_min = args.Iout_nom - (args.Iout_nom / 100 * args.Iout_deviation)
        var Iout_max = args.Iout_nom + (args.Iout_nom / 100 * args.Iout_deviation)
        var P_min = args.P_nom - (args.P_nom / 100 * args.P_deviation)
        var P_max = args.P_nom + (args.P_nom / 100 * args.P_deviation)
        var code = 0

        // Set PWM level
        if (_standApiObj.setPwmLevel(args.Pwm_level) === false)
        {
            code = Codes.CodeStandError
            avlog.show("red", code + ": ERROR: Set PWM level", false, true)
            return false
        }

        // Switch On Relay
        if (_standApiObj.setPioValue(1, 1) === false)
        {
            code = Codes.CodeStandError
            avlog.show("red", code + ": ERROR: Switch relay", false, true)
            return false
        }

        //----------------------------------------------------
        // Set input voltage (maximal)
        avlog.show("chocolate", "Check Input/Output current at " + args.Uin_max + "V ... Wait!", true, false)
        _power.setVoltage(args.Uin_max)
        wait(200)
        _power.loadOn()
        wait(4000)
        var Iin = _power.getMeasCurrent() * 1000
        var adc = _standApiObj.getAdcValue(1)
        var Iout = adc.ch1

        if (Iin > args.Iin_at_280)
        {
            code = Codes.CodeDrvInputCurrent280
            avlog.show("red", code + ": ERROR: Input current " + Iin.toFixed(2) + "mA at " + args.Uin_max + "V", false, true)
            return false
        }

        if (Iout > Iout_max || Iout < Iout_min)
        {
            code = Codes.CodeDrvOutputCurrent280
            avlog.show("red", code + ": ERROR: Output current " + Iout.toFixed(2) + "mA at " + args.Uin_max + "V", false, true)
            return false
        }

        avlog.show("green", "Input/Output current: " + Iin.toFixed(2) + " / " + Iout.toFixed(2) + "mA at " + args.Uin_max + "V ... OK", false, false)

        //----------------------------------------------------
        // Set input voltage (nominal)
        avlog.show("chocolate", "Check Input/Output current at " + args.Uin_nom + "V ... Wait!", true, false)
        _power.setVoltage(args.Uin_nom)
        wait(_measTimeout)

        Iin = _power.getMeasCurrent() * 1000
        adc = _standApiObj.getAdcValue(1)
        Iout = adc.ch1
        var PFactor = _power.getMeasPFactor()
        var Pin = _power.getMeasPower()

        if (PFactor < args.PFactor)
        {
            code = Codes.CodeDrvPowerFactor
            avlog.show("red", code + ": ERROR: Power Factor " + PFactor.toFixed(2) + " at " + args.Uin_nom + "V", false, true)
            return false
        }
        avlog.show("green", "Power Factor " + PFactor.toFixed(2) + " at " + args.Uin_nom + "V ... OK", false, false)

        if (Pin > P_max || Pin < P_min)
        {
            code = Codes.CodeDrvPower
            avlog.show("red", code + ": ERROR: Power " + Pin.toFixed(2) + "W at " + args.Uin_nom + "V", false, true)
            return false
        }
        avlog.show("green", "Power " + Pin.toFixed(2) + "W at " + args.Uin_nom + "V ... OK", false, false)

        if (Iin > args.Iin_at_220)
        {
            code = Codes.CodeDrvInputCurrent220
            avlog.show("red", code + ": ERROR: Input current " + Iin.toFixed(2) + "mA at " + args.Uin_nom + "V", false, true)
            return false
        }

        if (Iout > Iout_max || Iout < Iout_min)
        {
            code = Codes.CodeDrvOutputCurrent220
            avlog.show("red", code + ": ERROR: Output current " + Iout.toFixed(2) + "mA at " + args.Uin_nom + "V", false, true)
            return false
        }

        avlog.show("green", "Input/Output current: " + Iin.toFixed(2) + " / " + Iout.toFixed(2) + "mA at " + args.Uin_nom + "V ... OK", false, false)
//        wait(500)

        //----------------------------------------------------
        // Set input voltage (minimal)
        avlog.show("chocolate", "Check Input/Output current at " + args.Uin_min + "V ... Wait!", true, false)
        _power.setVoltage(args.Uin_min)
        wait(_measTimeout)
        Iin = _power.getMeasCurrent() * 1000
        adc = _standApiObj.getAdcValue(1)
        Iout = adc.ch1

        if (Iin > args.Iin_at_120)
        {
            code = Codes.CodeDrvInputCurrent120
            avlog.show("red", code + ": ERROR: Input current " + Iin.toFixed(2) + "mA at " + args.Uin_min + "V", false, true)
            return false
        }

        if (Iout > Iout_max || Iout < Iout_min)
        {
            code = Codes.CodeDrvOutputCurrent120
            avlog.show("red", code + ": ERROR: Output current " + Iout.toFixed(2) + "mA at " + args.Uin_min + "V", false, true)
            return false
        }

        avlog.show("green", "Input/Output current: " + Iin.toFixed(2) + " / " + Iout.toFixed(2) + "mA at " + args.Uin_min + "V ... OK", false, false)
        avlog.show("green", "Input/Output current measurement ... OK", false, false)

        //----------------------------------------------------
        // Smooth start
        _power.loadOff()
        wait(1000)
        _power.setVoltage(args.Uin_max)
        wait(1000)
        _power.setVoltage(args.Uin_nom)
        wait(500)

        return true
    }

    //-----------------------------------------------------------------
    // Measurement voltage of Controller and High voltage
    function stage2(args)
    {
        avlog.show("chocolate", "Measurement voltage of Controller and High voltage ... Running!", true, false)

        _power.setVoltage(args.Uin)
        wait(200)
        _power.loadOn()
        wait(_measTimeout)

        var adc = _standApiObj.getAdcValue(2)
        var Uctrl = adc.ch1 / 10
        var Uhigh = adc.ch2 / 10
        var code = 0

        if (Uctrl < args.Uctrl_min || Uctrl > args.Uctrl_max)
        {
            code = Codes.CodeDrvCtrlVoltage
            avlog.show("red", code + ": ERROR: Controller voltage:  " + Uctrl.toFixed(2) + " V", false, true)
            return false
        }

        if (Uhigh < args.Uhigh_min || Uhigh > args.Uhigh_max)
        {
            code = Codes.CodeDrvHighVoltage
            avlog.show("red", code + ": ERROR: High voltage:  " + Uhigh.toFixed(2) + " V", false, true)
            return false
        }

        avlog.show("green", "Controller/High voltage: " + Uctrl.toFixed(1) + " / " + Uhigh.toFixed(1) +  "V ... OK", false, false)
        avlog.show("green", "Measurement voltage of Controller and High voltage ... OK", false, false)
        wait(500)

        return true
    }

    //-----------------------------------------------------------------
    // Check the operation of the Dimming unit
    function stage3(args)
    {
        avlog.show("chocolate", "Check the operation of the Dimming unit ... Running!", true, false)

        _power.setVoltage(args.Uin)
        wait(200)
        _power.loadOn()
        wait(1000)

        var Iout_min = args.Iin_lev2 - (args.Iin_lev2 / 100 * args.Iin_deviation)
        var Iout_max = args.Iin_lev2 + (args.Iin_lev2 / 100 * args.Iin_deviation)
        var code = 0

        // Set PWM level 100%
        avlog.show("chocolate", "Check current at PWM " + args.Pwm_lev3 + "% ... Wait!", true, false)
        if (_standApiObj.setPwmLevel(args.Pwm_lev3) === false)
        {
            code = Codes.CodeStandError
            avlog.show("red", code + ": ERROR: Set PWM level", false, true)
            return false
        }
        wait(_measTimeout)
        var adc = _standApiObj.getAdcValue(1)
        var Iin = adc.ch1
        if (Iin > args.Iin_lev3)
        {
            code = Codes.CodeDrvOutputCurrent220
            avlog.show("red", code + ": ERROR: Current " + Iin.toFixed(2) + "mA at PWM " + args.Pwm_lev3 + "%", false, true)
            return false
        }
        avlog.show("green", "Current " + Iin.toFixed(2) + "mA at PWM " + args.Pwm_lev3 + "% ... OK", false, false)

        // Set PWM level 10%
        avlog.show("chocolate", "Check current at PWM " + args.Pwm_lev2 + "% ... Wait!", true, false)
        if (_standApiObj.setPwmLevel(args.Pwm_lev2) === false)
        {
            code = Codes.CodeStandError
            avlog.show("red", code + ": ERROR: Set PWM level", false, true)
            return false
        }
        wait(_measTimeout)
        adc = _standApiObj.getAdcValue(1)
        Iin = adc.ch1
        if (Iin < Iout_min || Iin > Iout_max)
        {
            code = Codes.CodeDrvOutputCurrent10
            avlog.show("red", code + ": ERROR: Current " + Iin.toFixed(2) + "mA at PWM " + args.Pwm_lev2 + "%", false, true)
            return false
        }
        avlog.show("green", "Current " + Iin.toFixed(2) + "mA at PWM " + args.Pwm_lev2 + "% ... OK", false, false)

        // Set PWM level 0%
        avlog.show("chocolate", "Check current at PWM " + args.Pwm_lev1 + "% ... Wait!", true, false)
        if (_standApiObj.setPwmLevel(args.Pwm_lev1) === false)
        {
            code = Codes.CodeStandError
            avlog.show("red", code + ": ERROR: Set PWM level", false, true)
            return false
        }
        wait(_measTimeout)
        adc = _standApiObj.getAdcValue(1)
        Iin = adc.ch1
        if (Iin > args.Iin_lev1)
        {
            code = Codes.CodeDrvOutputCurrent0
            avlog.show("red", code + ": ERROR: Current " + Iin.toFixed(2) + "mA at PWM " + args.Pwm_lev1 + "%", false, true)
            return false
        }
        avlog.show("green", "Current " + Iin.toFixed(2) + "mA at PWM " + args.Pwm_lev1 + "% ... OK", false, false)
        avlog.show("green", "Dimming Unit check ... OK", false, false)

        // Set PWM level 100%
        if (_standApiObj.setPwmLevel(args.Pwm_lev3) === false)
        {
            code = Codes.CodeStandError
            avlog.show("red", code + ": ERROR: Set PWM level", false, true)
            return false
        }
        wait(500)

        return true
    }

    //-----------------------------------------------------------------
    // No-load current measurement
    function stage4(args)
    {
        avlog.show("chocolate", "No-load current measurement ... Running!", true, false)
        var code = 0

        // Switch Off Relay
        if (_standApiObj.setPioValue(1, 0) === false)
        {
            code = Codes.CodeStandError
            avlog.show("red", code + ": ERROR: Switch relay", false, true)
            return false
        }

        _power.setVoltage(args.Uin)
        wait(200)
        _power.loadOn()
        wait(4000)

        var Iin = _power.getMeasCurrent() * 1000
        if (Iin > args.Iin)
        {
            code = Codes.CodeDrvNoLoadCurrent
            avlog.show("red", code + ": ERROR: No-load current " + Iin.toFixed(2) + "mA", false, true)
            return false
        }
        avlog.show("green", "No-load current " + Iin.toFixed(2) + "mA ... OK", false, false)
        avlog.show("green", "No-load current measurement ... OK", false, false)
        wait(500)

        return true
    }

    //-----------------------------------------------------------------

}


















