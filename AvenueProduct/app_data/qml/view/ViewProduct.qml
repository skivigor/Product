import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Styles 1.2
import QtGraphicalEffects 1.12
import "../widget"
import "../component"

Item
{
    id: root
    anchors.fill: parent
    property var _args     // _args[0] - name, _args[1] - image, _args[2] - _standProjPath, _args[3] - _fwProjPath
                           // _args[4] - box used, _args[5] - power supply used, _args[6] - imei used, _args[7] - hwType

    // Config for debug ------------------
    property bool  _productEnabled: settings.product.productEnabled           // full product process (only command line)
    property bool  _powerSupplyUsed: _args[5]                                 // use network PowerSupply (direct 220V)
    property bool  _emCalibrateEnabled: settings.product.emCalibrateEnabled   // electrical meter calibration
    property bool  _fwLoadEnabled: settings.product.fwLoadEnabled             // load firmware at BaseIni state
    property bool  _imeiUsed: _args[6]
    property int   _hwType: _args[7]
    //------------------------------------

    // Stand scope
    property var   _uart: new SerialClient("flag")
    property var   _stand: new Stand()
    property bool  _standInited: _stand.inited
    property var   _standApiObj
    property bool  _standBox: _args[4]

//    property var   _scanner: new Scanner()
    property var   _power: new PowerSupplyWithTcp(settings.power.tcp.defIp, settings.power.tcp.defPort)

    // HW scripts path
    property string  _standProjPath: "file:///" + AppPath + _args[2]
    property string  _standVerPath: _stand.swType + "/"
    property string  _standBoardPath
    property string  _standApiPath: _standProjPath + _standVerPath + "/StandApi.qml"
    property string  _standScriptsPath: _standProjPath + _standVerPath + _standBoardPath

    // FW scripts path
    property string  _fwProjPath: "file:///" + AppPath + _args[3]
    property string  _fwVerPath
    property string  _fwApiPath:  _fwProjPath + _fwVerPath + "../FwApi.qml"
    property var     _fwApi

    // Database objects
    property var     _objOrder: { "forder1c" : "", "forderdescription" : "", "fordereditems" : 0, "forderedinicount" : 0, "frefversion" : 0 }
    property var     _objEui
    property var     _objDevice
    property string  _vendorKey: ""
    property string  _devImei: ""

    // Stages
    property string  _stagePath: "file:///" + AppPath + "app_data/qml/stage/"    // Prebuild path
    property var   _stages: []
    property var   _stagesTempl: [
        {
            "path" : _stagePath,
            "file" : "Order.qml",
            "descr" : "Order processing",
            "args" : [],
            "prebuild" : true,
            "hwdefined" : false
        },
        {
            "path" : _fwProjPath,
            "file" : "FwCheck.qml",
            "descr" : "Firmware check",
            "args" : [ _objOrder.frefversion ],
            "prebuild" : true,
            "hwdefined" : false
        },
        {
            "path" : _stagePath,
            "file" : "ScanDevAndEui.qml",
            "descr" : "Scan Board ID and DevEUI",
            "args" : ["../../images/icon_board.png", "../../images/icon_cover.png"],
            "prebuild" : true,
            "hwdefined" : false
        },
        {
            "path" : _stagePath,
            "file" : "VendorAttr.qml",
            "descr" : "Search vendor attributes",
            "args" : [],
            "prebuild" : true,
            "hwdefined" : false
        },
        {
            "path" : _stagePath,
            "file" : "BoardInsert.qml",
            "descr" : "Board insert",
            "args" : ["Insert the Board to the Stand"],
            "prebuild" : true,
            "hwdefined" : false
        }
    ]

    // Temp variables
    property bool  _optionErrored: false
    property bool  _deviceRepetition: false
    property int   _currentStage: 0
    property var   _stageObj: null

    property var   _modeAcsObj: null

    //-----------------------------------------------------------------

    on_FwApiPathChanged:
    {
        if (_fwVerPath.length === 0) return
        console.log("!!!!!!!!!!!!!! FW API path: " + _fwApiPath)

        // Create Firmware API object
        _fwApi = Qt.createComponent(_fwApiPath).createObject(root, { "_iface" : _uart })
        if (_fwApi === null)
        {
            console.log("Work stopped: Firmware API object: " + _fwApiPath)
            avlog.show("red", "ERROR!!! Can not load Firmware API object", false, true)
            avlog.show("red", "Work stopped!!!")
            return
        }
    }

    on_StandInitedChanged:
    {
        if (_standInited)
        {
            id_timer.stop()

            // Create Stand API object
            _standApiObj = Qt.createComponent(_standApiPath).createObject(root, { "_iface" : _uart })
            if (_standApiObj === null)
            {
                console.log("Work stopped: Stand API object: " + _standApiPath)
                avlog.show("red", "ERROR!!! Can not load Stand API object", false, true)
                avlog.show("red", "Work stopped!!!")
                return
            }
            avlog.show("green", "Stand inited ... OK")

            if (!_productEnabled) return
            // Work mode ack
            var path = "file:///" + AppPath + "app_data/qml/component/CmpWorkMode.qml"
            _modeAcsObj = Qt.createComponent(path).createObject(root, { "_image" : "../../images/" + _args[1], "_text": _args[0] })
            if (_modeAcsObj === null)
            {
                console.log("Work stopped: Work mode object: " + path)
                avlog.show("red", "ERROR!!! Can not load Work Mode object", false, true)
                avlog.show("red", "Work stopped!!!")
                return
            }
            _modeAcsObj.modeAck.connect(onModeAck)

        } else
        {
            avlog.show("red", "ERROR!!! Can not init stand!!!", false, true)
            avlog.show("red", "Work stopped!!!")
        }
    }

    on_ObjOrderChanged:
    {
        id_wStat._orderNum = _objOrder.fordereditems
        id_wStat._orderCount = _objOrder.forderedinicount
    }

    //-----------------------------------------------------------------

    function onModeAck()
    {
        console.log("!!!!!!!! WORK MODE ACK")
        _modeAcsObj.destroy()
        _modeAcsObj = null
        process()
    }

    function nextStage()
    {
        _currentStage++
        if (_currentStage >= _stages.length) { finish(); return }
        id_timProc.start()
    }

    //-----------------------------------------------------------------

    function lastStage()
    {
        _currentStage = _stages.length - 1
        id_timProc.start()
    }

    //-----------------------------------------------------------------

    function process()
    {
        var stage = _stages[_currentStage]
        var path = {}
        var dirPath = {}

        if (stage.prebuild === true)
        {
            path = stage.path + stage.file
            _stageObj = Qt.createComponent(path).createObject(popup, { "_args" : stage.args })
        } else
        {
            if (stage.hwdefined === true)
            {
                dirPath = _standScriptsPath
                path = _standScriptsPath + stage.file
                stage.args.push(dirPath)
                _stageObj = Qt.createComponent(path).createObject(root, { "_args" : stage.args })
            } else
            {
                // Search file in version context or project context
                dirPath = _fwProjPath + _fwVerPath
                path = _fwProjPath + _fwVerPath + stage.file
                var ret = file.isFileExists(path)
                if (ret === false)
                {
                    dirPath = _fwProjPath + _fwVerPath + "../"
                    path = _fwProjPath + _fwVerPath + "../" + stage.file
                }
                stage.args.push(dirPath)
                _stageObj = Qt.createComponent(path).createObject(root, { "_args" : stage.args })
            }
        }

        if (_stageObj === null)
        {
            console.log("Work stopped: " + stage.descr)
            avlog.show("red", "ERROR!!! Can not load " + stage.file, false, true)
            avlog.show("red", "Work stopped!!!")
            return
        }

        _stageObj.executed.connect(onExecuted)
        _stageObj.stop.connect(onStop)
        id_timExec.start()
//        _stageObj.execute()
    }

    //-----------------------------------------------------------------

    function onExecuted(ret)
    {
        _stageObj.destroy()
        _stageObj = null

        if (ret === false)
        {
            _optionErrored = true
            console.log("Work stopped: " + _stages[_currentStage].file)
            lastStage()
            return
        }

        nextStage()
    }

    //-----------------------------------------------------------------

    function onStop()
    {
        _stageObj.destroy()
        _stageObj = null
        avlog.show("red", "Work stopped!!!")
        console.log("Work stopped: " + _stages[_currentStage].file)
    }

    //-----------------------------------------------------------------

    function finish()
    {
        _optionErrored = false
        _fwLoadEnabled = settings.product.fwLoadEnabled
        id_wStat._orderCount = _objOrder.forderedinicount

        if (_objOrder.forderedinicount < _objOrder.fordereditems)
        {
            _currentStage = 2
            id_timProc.start()
        } else
        {
//            The order is completed. To select another order, restart the application
            avlog.show("green", "The order is completed. \nTo select another order, restart the application", false, true)

//            _currentStage = 0
//            // Remove non prebuilded stages
//            _stages = []
//            _stages = _stagesTempl.slice()
//            id_timProc.start()
        }
    }

    //-----------------------------------------------------------------

    PropertyAnimation { target: root; property: "opacity";
        duration: 400; from: 0; to: 1;
        easing.type: Easing.InOutQuad ; running: true }

    Timer
    {
        id: id_timProc
        repeat: false
        running: false
        interval: 10
        onTriggered: process()
    }

    Timer
    {
        id: id_timer
        running: true
        repeat: false
        interval: 10000
        onTriggered:
        {
            avlog.show("red", "ERROR!!! Can not init stand!!!", false, true)
            avlog.show("red", "Work stopped!!!")
        }
    }

    Timer
    {
        id: id_timExec
        repeat: false
        running: false
        interval: 100
        onTriggered: _stageObj.execute()
    }

    CmpBoard
    {
        id: id_cmpStat
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 10
        width: 250
        height: id_wFirm.height < 200 ? 200 : id_wFirm.height
        WidgetOrderStat
        {
            id: id_wStat
            _orderDescr: _objOrder.forder1c
            _orderNum: _objOrder.fordereditems
            _orderCount: _objOrder.forderedinicount
        }
    }

    CmpBoard
    {
        id: id_cmpMes
        anchors.top: id_cmpStat.bottom
        anchors.left: parent.left
        anchors.margins: 10
        width: parent.width - 20
        height: 60
        CmpTransparant { id: id_cmpTransparant }
    }

    WidgetFirmware
    {
        id: id_wFirm
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 10
        _model: _stand.getFwModel()
    }

    WidgetLog
    {
        id: id_wLog
        anchors.top: id_cmpMes.bottom
        anchors.topMargin: 10
        anchors.bottom: settings.conf.debug ? id_wStandDebug.top : parent.bottom
        anchors.bottomMargin: 15
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - 40
        _log: avlog.mesProduct
    }

    WidgetStandDebug
    {
        id: id_wStandDebug
        visible: settings.conf.debug
        standObj: _uart
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 30
    }

    Item
    {
        id: popup
        width: parent.width
        anchors.top: parent.top
        anchors.bottom: id_wLog.top
        anchors.bottomMargin: 5
    }

    Component.onCompleted:
    {
        id_mainWindow.width = 800
        id_mainWindow.height = 700
        id_mainWindow.minimumWidth = 800
        id_mainWindow.minimumHeight = 700
        id_mainWindow._header = _args[0]

        scanner.open()
        wait(300)
        var ret = scanner.isOpenned()
        if (ret === true)
        {
            avlog.show("green", "Scanner port check ... OK")
            scanner.close()
        } else
        {
            avlog.show("red", "Can not open Scanner port!!!", false, true)
            avlog.show("red", "Work stopped!!!")
            return
        }

        _stages = []
        _stages = _stagesTempl.slice()

        avlog.show("chocolate", "Wait! Stand initing ...")
        _uart.connectSerial(settings.stand.uart, settings.stand.speed)
        _stand.setSerialLink(_uart)
        _stand.init()
    }
}
