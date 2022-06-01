//#include "fwuploader.h"
//#include "trans/connection.h"
//#include "firmware.h"

//#include <QDebug>
////#include <QTest>

//namespace
//{
//const quint8 FlagSerial = 0xFA;
//const quint8 FlagEsp =    0xFB;

//const quint8 BootCmdInit =     0x7F;
//const quint8 BootCmdErase =    0x44;
//const quint8 BootCmdEraseCrc = 0xBB;
//const quint8 BootCmdWrite =    0x31;
//const quint8 BootCmdWriteCrc = 0xCE;
//const quint8 BootCmdRead =     0x11;
//const quint8 BootCmdReadCrc =  0xEE;
//const quint8 BootAnsOk =       0x79;

//// Old ESP firmware (mode 0) ------------
//const quint8 EspCmdPin =  0x02;
//const quint8 PinSet =     1;
//const quint8 PinReset =   0;

//const quint8 EspCmdPinMode =      0x03;
//const quint8 PinModeInput =       0x01;
////quint8 PinModeInputPullup = 0x02;
//const quint8 PinModeOutput =      0x03;
////---------------------------------------

//// New ESP firmware (mode 1) ------------
//const quint8 NEspFuncCode = 0x71;
//const quint8 NUartFuncCode = 0x70;

//const quint8 NEspGetPinState = 0x02;
//const quint8 NEspSetPinState = 0x03;
//    const quint8 NEspPinStateSet =   0x01;
//    const quint8 NEspPinStateReset = 0x00;

//const quint8 NEspGetPinMode = 0x04;
//const quint8 NEspSetPinMode = 0x05;
//    const quint8 NEspPinModeInput =  0x01;
//    const quint8 NEspPinModeOutput = 0x03;
////---------------------------------------

//int FwPageSize =      128;
//int CheckTimeout =    10;
//int AlarmTimeout =    7000;

//bool reseting = false;
//}    // namespace


//namespace load
//{

//FwUploader::FwUploader(trans::Connection &conn, Firmware &firm, quint8 pinBoot, quint8 pinRst, QObject *parent)
//    : m_conn(conn),
//      m_firm(firm),
//      m_mode(0),
//      m_pinBoot(pinBoot),
//      m_pinRst(pinRst),
//      m_stage(STAGE_IDLE),
//      m_strStatus(""),
//      m_bError(false),
//      m_bUploading(false),
//      m_bVerify(false)
//{
//    Q_UNUSED(parent);

//    QObject::connect(&m_conn, SIGNAL(rcvData(QByteArray)), this, SLOT(onRcvData(QByteArray)));

//    m_timer.setSingleShot(true);
//    QObject::connect(&m_timer, SIGNAL(timeout()), this, SLOT(onTimeout()), Qt::QueuedConnection);
//}

//FwUploader::~FwUploader()
//{
//}


////-----------------------------------------------------------------

//void FwUploader::onRcvData(QByteArray data)
//{
//    if (!m_bUploading || data.isEmpty()) return;

//    if (m_mode == 0)
//    {
//        quint8 flag = data.at(0);

//        if (flag == FlagSerial)
//        {
//            QByteArray rep;
//            rep.append(0xFA);
//            rep.append(0xFA);
//            rep.append(0xFA);
//            rep.append(0xFA);
//            data.replace(rep, QByteArray());
//            m_data.append(data);
//            return;
//        }

//        if (flag == FlagEsp)
//        {
//            data.remove(0, 1);
//            m_data.append(data);
//            return;
//        }
//    } else
//    {
//        m_data = data;
//        //qDebug() << "FwUploader::onRcvData: data: " << m_data.toHex();
//    }
//}

////-----------------------------------------------------------------

//void FwUploader::onTimeout()
//{
//    m_data.clear();
//    m_strStatus = "Uploading error";
//    m_bError = true;
//    m_bUploading = false;
//    emit strStatusChanged();
//    emit errorChanged();
//    emit uploadingChanged();
//    resetDevice();

//    resetStages();
//}

////-----------------------------------------------------------------

//void FwUploader::stageComplete()
//{
//    if (m_stage == STAGE_IDLE)
//    {
//        qDebug() << "FwUploader::stageComplete: STAGE IDLE";
//        m_strStatus = "Upload complete: OK";
//        m_bError = false;
//        m_bUploading = false;
//        emit errorChanged();
//        emit uploadingChanged();
//        emit strStatusChanged();
//    }

//    if (m_stage == STAGE_BOOT)
//    {
//        qDebug() << "FwUploader::stageComplete: STAGE_BOOT complete";
//        m_stage = STAGE_ERASE;
//        eraseFlash();

////        m_stage = STAGE_VERIF;
////        verifyFlash();
//        return;
//    }

//    if (m_stage == STAGE_ERASE)
//    {
//        qDebug() << "FwUploader::stageComplete: STAGE_ERASE complete";
//        m_stage = STAGE_WRITE;
//        writeFlash();
//        return;
//    }

//    if (m_stage == STAGE_WRITE)
//    {
//        qDebug() << "FwUploader::stageComplete: STAGE_WRITE complete";
//        if (m_bVerify)
//        {
//            m_stage = STAGE_VERIF;
//            verifyFlash();
//        } else
//        {
//            m_stage = STAGE_IDLE;
//            goToWork();
//        }
//        return;
//    }

//    if (m_stage == STAGE_VERIF)
//    {
//        qDebug() << "FwUploader::stageComplete: STAGE_VERIF complete";
//        m_stage = STAGE_IDLE;
//        goToWork();
//        return;
//    }
//}

////-----------------------------------------------------------------

//void FwUploader::resetStages()
//{
//    m_stage = STAGE_IDLE;
//    reseting = true;

//    // Reset Stages
//    goToBoot();
//    eraseFlash();
//    writeFlash();
//    goToWork();

//    reseting = false;
//}

////-----------------------------------------------------------------

//void FwUploader::errorHandler(const QString &status)
//{
//    qDebug() << "Error handler: " << status;
//    m_timer.stop();
//    m_bError = true;
//    m_bUploading = false;
//    m_strStatus = status;
//    m_data.clear();

//    emit errorChanged();
//    emit uploadingChanged();
//    emit strStatusChanged();
//    resetStages();
//}

////-----------------------------------------------------------------

//void FwUploader::uploadFirmware()
//{
//    if (!m_conn.isConnected() || m_bUploading) return;

//    m_timer.stop();
//    resetStages();
//    m_bError = false;
//    m_bUploading = true;
//    m_strStatus = "Uploading ...";
//    m_data.clear();

//    emit errorChanged();
//    emit uploadingChanged();
//    emit strStatusChanged();

//    m_stage = STAGE_BOOT;
//    goToBoot();
//}

////-----------------------------------------------------------------

//void FwUploader::goToBoot()
//{
//    enum Stage { SET_BOOT, SET_RST, BOOT_TO_1, RST_TO_0, RST_TO_1, CONF_BOOT };
//    static Stage stg = SET_BOOT;
//    static bool waitAns = false;

//    if (!m_conn.isConnected() || m_bError || reseting) { stg = SET_BOOT; waitAns = false; return; }

//    // Set Boot pin mode to Output & check answer
//    if (stg == SET_BOOT)
//    {
//        if (waitAns)
//        {
//            qDebug() << "Wait Ans SET_BOOT";
//            if (m_data.isEmpty()) { QTimer::singleShot(CheckTimeout, this, SLOT(goToBoot())); return; }

//            qDebug() << "Ans SET_BOOT: " << m_data.toHex();
//            m_timer.stop();
//            if (m_mode == 0)
//            {
//                if (m_data.size() != 4) { errorHandler("Bootloader error"); return; }

//                quint8 cmd = m_data.at(0);
//                quint8 pin = m_data.at(1);
//                quint8 mode = m_data.at(2);
//                quint8 set = m_data.at(3);
//                if (cmd != EspCmdPinMode || pin != m_pinBoot || mode != PinModeOutput || set != PinReset) { errorHandler("Bootloader error"); return; }
//            } else
//            {
//                if (m_data.size() != 3) { errorHandler("Bootloader error"); return; }
//                quint8 func = m_data.at(1);
//                quint8 attr = m_data.at(2);
//                if (func != NEspFuncCode || attr != NEspSetPinMode) { errorHandler("Bootloader error"); return; }
//            }

//            m_data.clear();
//            waitAns = false;
//            stg = SET_RST;
//            QTimer::singleShot(100, this, SLOT(goToBoot()));
//            return;
//        }

//        m_data.clear();
//        QByteArray ba;
//        if (m_mode == 0)
//        {
//            ba.append(static_cast<char>(FlagEsp));
//            ba.append(static_cast<char>(EspCmdPinMode));
//            ba.append(static_cast<char>(m_pinBoot));
//            ba.append(static_cast<char>(PinModeOutput));
//            ba.append(static_cast<char>(PinReset));
//        } else
//        {
//            ba.append(0x05);
//            ba.append(static_cast<char>(NEspFuncCode));
//            ba.append(static_cast<char>(NEspSetPinMode));
//            ba.append(static_cast<char>(m_pinBoot));
//            ba.append(static_cast<char>(NEspPinModeOutput));
//        }
//        sendData(ba);

//        waitAns = true;
//        QTimer::singleShot(100, this, SLOT(goToBoot()));
//        m_timer.start(AlarmTimeout);
//        return;
//    }

//    // Set Rst pin mode to Output & check answer
//    if (stg == SET_RST)
//    {
//        if (waitAns)
//        {
//            qDebug() << "Wait Ans SET_RST";
//            if (m_data.isEmpty()) { QTimer::singleShot(CheckTimeout, this, SLOT(goToBoot())); return; }

//            m_timer.stop();
//            if (m_mode == 0)
//            {
//                if (m_data.size() != 4) { errorHandler("Bootloader error"); return; }

//                quint8 cmd = m_data.at(0);
//                quint8 pin = m_data.at(1);
//                quint8 mode = m_data.at(2);
//                quint8 set = m_data.at(3);
//                if (cmd != EspCmdPinMode || pin != m_pinRst || mode != PinModeOutput || set != PinSet) { errorHandler("Bootloader error"); return; }
//            } else
//            {
//                if (m_data.size() != 3) { errorHandler("Bootloader error"); return; }
//                quint8 func = m_data.at(1);
//                quint8 attr = m_data.at(2);
//                if (func != NEspFuncCode || attr != NEspSetPinMode) { errorHandler("Bootloader error"); return; }
//            }

//            m_data.clear();
//            waitAns = false;
//            stg = BOOT_TO_1;
//            QTimer::singleShot(100, this, SLOT(goToBoot()));
//            return;
//        }

//        m_data.clear();
//        QByteArray ba;
//        if (m_mode == 0)
//        {
//            ba.append(static_cast<char>(FlagEsp));
//            ba.append(static_cast<char>(EspCmdPinMode));
//            ba.append(static_cast<char>(m_pinRst));
//            ba.append(static_cast<char>(PinModeOutput));
//            ba.append(static_cast<char>(PinSet));
//        } else
//        {
//            ba.append(0x05);
//            ba.append(static_cast<char>(NEspFuncCode));
//            ba.append(static_cast<char>(NEspSetPinMode));
//            ba.append(static_cast<char>(m_pinRst));
//            ba.append(static_cast<char>(NEspPinModeOutput));
//        }
//        sendData(ba);

//        waitAns = true;
//        QTimer::singleShot(100, this, SLOT(goToBoot()));
//        m_timer.start(AlarmTimeout);
//        return;
//    }


//    // Set Boot pin to 1 & check answer
//    if (stg == BOOT_TO_1)
//    {
//        if (waitAns)
//        {
//            qDebug() << "Wait Ans BOOT_TO_1";
//            if (m_data.isEmpty()) { QTimer::singleShot(CheckTimeout, this, SLOT(goToBoot())); return; }

//            m_timer.stop();
//            if (m_mode == 0)
//            {
//                if (m_data.size() != 3) { errorHandler("Bootloader error"); return; }

//                quint8 cmd = m_data.at(0);
//                quint8 pin = m_data.at(1);
//                quint8 set = m_data.at(2);
//                if (cmd != EspCmdPin || pin != m_pinBoot || set != PinSet) { errorHandler("Bootloader error"); return; }
//            } else
//            {
//                if (m_data.size() != 3) { errorHandler("Bootloader error"); return; }
//                quint8 func = m_data.at(1);
//                quint8 attr = m_data.at(2);
//                if (func != NEspFuncCode || attr != NEspSetPinState) { errorHandler("Bootloader error"); return; }
//            }

//            m_data.clear();
//            waitAns = false;
//            stg = RST_TO_0;
//            QTimer::singleShot(100, this, SLOT(goToBoot()));
//            return;
//        }

//        m_data.clear();
//        QByteArray ba;
//        if (m_mode == 0)
//        {
//            ba.append(static_cast<char>(FlagEsp));
//            ba.append(static_cast<char>(EspCmdPin));
//            ba.append(static_cast<char>(m_pinBoot));
//            ba.append(static_cast<char>(PinSet));
//        } else
//        {
//            ba.append(0x05);
//            ba.append(static_cast<char>(NEspFuncCode));
//            ba.append(static_cast<char>(NEspSetPinState));
//            ba.append(static_cast<char>(m_pinBoot));
//            ba.append(static_cast<char>(NEspPinStateSet));
//        }
//        sendData(ba);

//        waitAns = true;
//        QTimer::singleShot(100, this, SLOT(goToBoot()));
//        m_timer.start(AlarmTimeout);
//        return;
//    }

//    // Set Reset pin to 0 & check answer
//    if (stg == RST_TO_0)
//    {
//        if (waitAns)
//        {
//            qDebug() << "Wait Ans RST_TO_0";
//            if (m_data.isEmpty()) { QTimer::singleShot(CheckTimeout, this, SLOT(goToBoot())); return; }

//            m_timer.stop();
//            if (m_mode == 0)
//            {
//                if (m_data.size() != 3) { errorHandler("Bootloader error"); return; }

//                quint8 cmd = m_data.at(0);
//                quint8 pin = m_data.at(1);
//                quint8 set = m_data.at(2);
//                if (cmd != EspCmdPin || pin != m_pinRst || set != PinReset) { errorHandler("Bootloader error"); return; }
//            } else
//            {
//                if (m_data.size() != 3) { errorHandler("Bootloader error"); return; }
//                quint8 func = m_data.at(1);
//                quint8 attr = m_data.at(2);
//                if (func != NEspFuncCode || attr != NEspSetPinState) { errorHandler("Bootloader error"); return; }
//            }

//            m_data.clear();
//            waitAns = false;
//            stg = RST_TO_1;
//            QTimer::singleShot(100, this, SLOT(goToBoot()));
//            return;
//        }

//        m_data.clear();
//        QByteArray ba;
//        if (m_mode == 0)
//        {
//            ba.append(static_cast<char>(FlagEsp));
//            ba.append(static_cast<char>(EspCmdPin));
//            ba.append(static_cast<char>(m_pinRst));
//            ba.append(static_cast<char>(PinReset));
//        } else
//        {
//            ba.append(0x05);
//            ba.append(static_cast<char>(NEspFuncCode));
//            ba.append(static_cast<char>(NEspSetPinState));
//            ba.append(static_cast<char>(m_pinRst));
//            ba.append(static_cast<char>(NEspPinStateReset));
//        }
//        sendData(ba);

//        waitAns = true;
//        QTimer::singleShot(100, this, SLOT(goToBoot()));
//        m_timer.start(AlarmTimeout);
//        return;
//    }

//    // Set Reset pin to 1 & check answer
//    if (stg == RST_TO_1)
//    {
//        if (waitAns)
//        {
//            qDebug() << "Wait Ans RST_TO_1";
//            if (m_data.isEmpty()) { QTimer::singleShot(CheckTimeout, this, SLOT(goToBoot())); return; }

//            m_timer.stop();
//            if (m_mode == 0)
//            {
//                if (m_data.size() != 3) { errorHandler("Bootloader error"); return; }

//                quint8 cmd = m_data.at(0);
//                quint8 pin = m_data.at(1);
//                quint8 set = m_data.at(2);
//                if (cmd != EspCmdPin || pin != m_pinRst || set != PinSet) { errorHandler("Bootloader error"); return; }
//            } else
//            {
//                if (m_data.size() != 3) { errorHandler("Bootloader error"); return; }
//                quint8 func = m_data.at(1);
//                quint8 attr = m_data.at(2);
//                if (func != NEspFuncCode || attr != NEspSetPinState) { errorHandler("Bootloader error"); return; }
//            }

//            m_data.clear();
//            waitAns = false;
//            stg = CONF_BOOT;
//            QTimer::singleShot(100, this, SLOT(goToBoot()));
//            return;
//        }

//        m_data.clear();
//        QByteArray ba;
//        if (m_mode == 0)
//        {
//            ba.append(static_cast<char>(FlagEsp));
//            ba.append(static_cast<char>(EspCmdPin));
//            ba.append(static_cast<char>(m_pinRst));
//            ba.append(static_cast<char>(PinSet));
//        } else
//        {
//            ba.append(0x05);
//            ba.append(static_cast<char>(NEspFuncCode));
//            ba.append(static_cast<char>(NEspSetPinState));
//            ba.append(static_cast<char>(m_pinRst));
//            ba.append(static_cast<char>(NEspPinStateSet));
//        }
//        sendData(ba);

//        waitAns = true;
//        QTimer::singleShot(100, this, SLOT(goToBoot()));
//        m_timer.start(AlarmTimeout);
//        return;
//    }

//    // Configure Bootloader & check answer
//    if (stg == CONF_BOOT)
//    {
//        if (waitAns)
//        {
//            qDebug() << "Wait Ans CONF_BOOT";
//            if (m_data.isEmpty()) { QTimer::singleShot(CheckTimeout, this, SLOT(goToBoot())); return; }

//            m_timer.stop();
//            if (m_mode == 0)
//            {
//                if (m_data.size() != 1) { errorHandler("Bootloader error"); return; }

//                quint8 cmd = m_data.at(0);
//                if (cmd != BootAnsOk) { errorHandler("Bootloader error"); return; }
//            } else
//            {
//                if (m_data.size() != 3) { errorHandler("Bootloader error"); return; }
//                quint8 func = m_data.at(1);
//                quint8 cmd = m_data.at(2);
//                if (func != NUartFuncCode || cmd != BootAnsOk) { errorHandler("Bootloader error"); return; }
//            }

//            // Finish goToWork stage
//            m_data.clear();
//            waitAns = false;
//            stg = SET_BOOT;
//            stageComplete();
//            return;
//        }

//        m_data.clear();
//        QByteArray ba;
//        if (m_mode == 0)
//        {
//            ba.append(static_cast<char>(FlagSerial));
//            ba.append(static_cast<char>(BootCmdInit));
//        } else
//        {
//            ba.append(0x03);
//            ba.append(NUartFuncCode);
//            ba.append(BootCmdInit);
//        }
//        sendData(ba);

//        waitAns = true;
//        QTimer::singleShot(100, this, SLOT(goToBoot()));
//        m_timer.start(AlarmTimeout);
//        return;
//    }
//}

////-----------------------------------------------------------------

//void FwUploader::eraseFlash()
//{
//    enum Stage { IDLE, CMD_ERASE, PAGE_ERASE };
//    static Stage stg = IDLE;
//    static int step = 1;

//    if (!m_conn.isConnected() || m_bError || reseting) { stg = IDLE; step = 1; return; }

//    m_strStatus = "Erase flash ...";
//    emit strStatusChanged();

//    // Send Erase command
//    if (stg == IDLE)
//    {
//        m_data.clear();
//        QByteArray ba;

//        if (m_mode == 0)
//        {
//            ba.append(static_cast<char>(FlagSerial));
//        } else
//        {
//            ba.append(0x04);
//            ba.append(NUartFuncCode);
//        }

//        ba.append(static_cast<char>(BootCmdErase));
//        ba.append(static_cast<char>(BootCmdEraseCrc));

//        sendData(ba);
//        stg = CMD_ERASE;
//        QTimer::singleShot(CheckTimeout, this, SLOT(eraseFlash()));
//        m_timer.start(AlarmTimeout);
//        return;
//    }

//    // Check answer on Erase command
//    if (stg == CMD_ERASE)
//    {
////        qDebug() << "Check Erase Cmd";
//        if (m_data.isEmpty()) { QTimer::singleShot(CheckTimeout, this, SLOT(eraseFlash())); return; }

//        m_timer.stop();
//        if (m_mode == 0)
//        {
//            if (m_data.size() != 1) { errorHandler("Erase error"); return; }
//            quint8 cmd = m_data.at(0);
//            if (cmd != BootAnsOk) { errorHandler("Erase error"); return; }
//        } else
//        {
//            if (m_data.size() != 3) { errorHandler("Bootloader error"); return; }
//            quint8 func = m_data.at(1);
//            quint8 cmd = m_data.at(2);
//            if (func != NUartFuncCode || cmd != BootAnsOk) { errorHandler("Bootloader error"); return; }
//        }

//        m_data.clear();
//        stg = PAGE_ERASE;
//        QTimer::singleShot(CheckTimeout, this, SLOT(eraseFlash()));
//        return;
//    }

//    // Erase pages
//    int pages = m_firm.getFileSize() / FwPageSize + 1;
////    int stepsNum = pages / 128 + 1;
//    int stepsNum = pages / 96 + 1;
//    quint8 zero = 0x00;
//    quint8 hnum = 0;
//    quint8 lnum = 0;

//    static bool waitAnswer = false;
//    if (stg == PAGE_ERASE)
//    {
////        qDebug() << "ERASE PAGES STATE";
//        if (step > 1 && waitAnswer)
//        {
//            if (m_data.isEmpty()) { QTimer::singleShot(CheckTimeout, this, SLOT(eraseFlash())); return; }

//            m_timer.stop();
//            if (m_mode == 0)
//            {
//                if (m_data.size() != 1) { errorHandler("Erase error"); return; }
//                quint8 cmd = m_data.at(0);
//                if (cmd != BootAnsOk) { errorHandler("Erase error"); return; }
//            } else
//            {
//                if (m_data.size() != 3) { errorHandler("Bootloader error"); return; }
//                quint8 func = m_data.at(1);
//                quint8 cmd = m_data.at(2);
//                if (func != NUartFuncCode || cmd != BootAnsOk) { errorHandler("Bootloader error"); return; }
//            }

//            if (step > stepsNum)
//            {
//                waitAnswer = false;
//                step = 1;
//                stg = IDLE;
//                m_data.clear();
//                stageComplete();
//                return;
//            }

//            waitAnswer = false;
//            stg = IDLE;
//            QTimer::singleShot(CheckTimeout, this, SLOT(eraseFlash()));
//            return;
//        }

//        m_data.clear();
//        QByteArray ba;
//        ba.append(zero);
//        ba.append(95);

//        for (quint16 i = (step - 1) * 96; i < step * 96; ++i)
//        {
//            hnum = (i >> 8) & 0xFF;
//            lnum = i & 0xFF;
//            ba.append(hnum);
//            ba.append(lnum);
//        }

//        quint8 chsum = 0;
//        for (int i = 0; i < ba.size(); ++i) chsum ^= ba.at(i);
//        ba.append(chsum);
//        if (m_mode == 0)
//        {
//            ba.prepend(static_cast<char>(FlagSerial));
//        } else
//        {
//            ba.prepend(NUartFuncCode);
//            quint8 size = ba.size() + 1;
//            ba.prepend(size);
//        }
//        sendData(ba);

//        waitAnswer = true;
//        step++;
//        QTimer::singleShot(CheckTimeout, this, SLOT(eraseFlash()));
//        m_timer.start(AlarmTimeout);
//    }
//}

////-----------------------------------------------------------------

//void FwUploader::writeFlash()
//{
//    enum Stage { CMD_WRITE, ADDR_WRITE, DATA_WRITE };
//    static Stage stg = CMD_WRITE;
//    static int block = 1;
//    quint32 startAddr = 0x08000000;
//    static bool waitAns = false;

//    if (!m_conn.isConnected() || m_bError || reseting)
//    {
//        stg = CMD_WRITE;
//        block = 1;
//        waitAns = false;
//        return;
//    }

//    // Show Write start status
//    if (block == 1) { m_strStatus = "Write flash ... 0 %"; emit strStatusChanged(); }

//    // Send Write command & check answer
//    if (stg == CMD_WRITE)
//    {
//        if (waitAns)
//        {
//            if (m_data.isEmpty()) { QTimer::singleShot(CheckTimeout, this, SLOT(writeFlash())); return; }

//            m_timer.stop();
//            if (m_mode == 0)
//            {
//                if (m_data.size() != 1) { errorHandler("Write error"); return; }
//                quint8 cmd = m_data.at(0);
//                if (cmd != BootAnsOk) { errorHandler("Write error"); return; }
//            } else
//            {
//                if (m_data.size() != 3) { errorHandler("Bootloader error"); return; }
//                quint8 func = m_data.at(1);
//                quint8 cmd = m_data.at(2);
//                if (func != NUartFuncCode || cmd != BootAnsOk) { errorHandler("Bootloader error"); return; }
//            }

//            m_data.clear();
//            waitAns = false;
//            stg = ADDR_WRITE;
//            QTimer::singleShot(1, this, SLOT(writeFlash()));
//            return;
//        }

//        m_data.clear();
//        QByteArray ba;
//        if (m_mode == 0)
//        {
//            ba.append(static_cast<char>(FlagSerial));
//        } else
//        {
//            ba.append(0x04);
//            ba.append(NUartFuncCode);
//        }
//        ba.append(BootCmdWrite);
//        ba.append(BootCmdWriteCrc);
//        sendData(ba);

//        waitAns = true;
//        QTimer::singleShot(CheckTimeout, this, SLOT(writeFlash()));
//        m_timer.start(AlarmTimeout);
//        return;
//    }

//    // Calculate and Send Addr & check answer
//    if (stg == ADDR_WRITE)
//    {
//        if (waitAns)
//        {
//            if (m_data.isEmpty()) { QTimer::singleShot(CheckTimeout, this, SLOT(writeFlash())); return; }

//            m_timer.stop();
//            if (m_mode == 0)
//            {
//                if (m_data.size() != 1) { errorHandler("Write error"); return; }
//                quint8 cmd = m_data.at(0);
//                if (cmd != BootAnsOk) { errorHandler("Write error"); return; }
//            } else
//            {
//                if (m_data.size() != 3) { errorHandler("Bootloader error"); return; }
//                quint8 func = m_data.at(1);
//                quint8 cmd = m_data.at(2);
//                if (func != NUartFuncCode || cmd != BootAnsOk) { errorHandler("Bootloader error"); return; }
//            }

//            m_data.clear();
//            waitAns = false;
//            stg = DATA_WRITE;
//            QTimer::singleShot(1, this, SLOT(writeFlash()));
//            return;
//        }

//        m_data.clear();
//        QByteArray ba;
//        quint32 addr = startAddr + (block - 1) * m_firm.getMaxBlockSize();
//        ba.append((addr >> 24) & 0xFF);
//        ba.append((addr >> 16) & 0xFF);
//        ba.append((addr >> 8) & 0xFF);
//        ba.append(addr & 0xFF);
//        quint8 chsum = 0;
//        for (int i = 0; i < ba.size(); ++i) chsum ^= ba.at(i);
//        ba.append(chsum);
//        if (m_mode == 0)
//        {
//            ba.prepend(static_cast<char>(FlagSerial));
//        } else
//        {
//            ba.prepend(NUartFuncCode);
//            ba.prepend(ba.size() + 1);
//        }
//        sendData(ba);

//        waitAns = true;
//        QTimer::singleShot(CheckTimeout, this, SLOT(writeFlash()));
//        m_timer.start(AlarmTimeout);
//        return;
//    }

//    int blocksNum = m_firm.getBlocksNum();
//    // Write Data & check answer
//    if (stg == DATA_WRITE)
//    {
//        if (waitAns)
//        {
//            if (m_data.isEmpty()) { QTimer::singleShot(CheckTimeout, this, SLOT(writeFlash())); return; }

//            m_timer.stop();
//            if (m_mode == 0)
//            {
//                if (m_data.size() != 1) { errorHandler("Write error"); return; }
//                quint8 cmd = m_data.at(0);
//                if (cmd != BootAnsOk) { errorHandler("Write error"); return; }
//            } else
//            {
//                if (m_data.size() != 3) { errorHandler("Bootloader error"); return; }
//                quint8 func = m_data.at(1);
//                quint8 cmd = m_data.at(2);
//                if (func != NUartFuncCode || cmd != BootAnsOk) { errorHandler("Bootloader error"); return; }
//            }

//            if (block > blocksNum)
//            {
//                waitAns = false;
//                block = 1;
//                stg = CMD_WRITE;
//                m_data.clear();
//                stageComplete();
//                return;
//            }

//            m_data.clear();
//            waitAns = false;
//            stg = CMD_WRITE;
//            QTimer::singleShot(1, this, SLOT(writeFlash()));
//            return;
//        }

//        m_data.clear();
//        qDebug() << "Write block: " << block;
//        if (block % 10 == 0)
//        {
//            int percent = block * 100 / blocksNum;
//            m_strStatus = QString("Write flash ... %1 %").arg(QString::number(percent));
//            emit strStatusChanged();
//        }

//        QByteArray ba = m_firm.getBlock(block);
//        int size = ba.size() - 1;
//        ba.prepend(size & 0xFF);
//        quint8 chsum = 0;
//        for (int i = 0; i < ba.size(); ++i) chsum ^= ba.at(i);
//        ba.append(chsum);
//        if (m_mode == 0)
//        {
//            ba.prepend(static_cast<char>(FlagSerial));
//        } else
//        {
//            ba.prepend(NUartFuncCode);
//            ba.prepend(ba.size() + 1);
//        }
//        sendData(ba);

//        waitAns = true;
//        block++;
//        QTimer::singleShot(CheckTimeout, this, SLOT(writeFlash()));
//        m_timer.start(AlarmTimeout);
//        return;
//    }
//}

////-----------------------------------------------------------------

//void FwUploader::verifyFlash()
//{
//    enum Stage { CMD_READ, ADDR_READ, DATA_READ };
//    static Stage stg = CMD_READ;
//    static int block = 1;
//    quint32 startAddr = 0x08000000;
//    static bool waitAns = false;

//    if (!m_conn.isConnected() || m_bError || reseting)
//    {
//        stg = CMD_READ;
//        block = 1;
//        waitAns = false;
//        return;
//    }

//    // Show Read start status
//    if (block == 1) { m_strStatus = "Verify flash ... 0 %"; emit strStatusChanged(); }

//    // Send Read command & check answer
//    if (stg == CMD_READ)
//    {
//        if (waitAns)
//        {
//            if (m_data.isEmpty()) { QTimer::singleShot(CheckTimeout, this, SLOT(verifyFlash())); return; }

//            m_timer.stop();
//            if (m_mode == 0)
//            {
//                if (m_data.size() != 1) { errorHandler("Read error"); return; }
//                quint8 cmd = m_data.at(0);
//                if (cmd != BootAnsOk) { errorHandler("Read error"); return; }
//            } else
//            {
//                //
//            }

//            m_data.clear();
//            waitAns = false;
//            stg = ADDR_READ;
//            QTimer::singleShot(1, this, SLOT(verifyFlash()));
//            return;
//        }

//        m_data.clear();
//        QByteArray ba;
//        if (m_mode == 0)
//        {
//            ba.append(static_cast<char>(FlagSerial));
//        } else
//        {
//            //
//        }
//        ba.append(BootCmdRead);
//        ba.append(BootCmdReadCrc);
//        sendData(ba);

//        waitAns = true;
//        QTimer::singleShot(CheckTimeout, this, SLOT(verifyFlash()));
//        m_timer.start(AlarmTimeout);
//        return;
//    }

//    // Calculate and Send Addr & check answer
//    if (stg == ADDR_READ)
//    {
//        if (waitAns)
//        {
//            if (m_data.isEmpty()) { QTimer::singleShot(CheckTimeout, this, SLOT(verifyFlash())); return; }

//            m_timer.stop();
//            if (m_mode == 0)
//            {
//                if (m_data.size() != 1) { errorHandler("Read error"); return; }
//                quint8 cmd = m_data.at(0);
//                if (cmd != BootAnsOk) { errorHandler("Read error"); return; }
//            } else
//            {
//                //
//            }

//            m_data.clear();
//            waitAns = false;
//            stg = DATA_READ;
//            QTimer::singleShot(1, this, SLOT(verifyFlash()));
//            return;
//        }

//        m_data.clear();
//        QByteArray ba;
//        quint32 addr = startAddr + (block - 1) * m_firm.getMaxBlockSize();
//        ba.append((addr >> 24) & 0xFF);
//        ba.append((addr >> 16) & 0xFF);
//        ba.append((addr >> 8) & 0xFF);
//        ba.append(addr & 0xFF);
//        quint8 chsum = 0;
//        for (int i = 0; i < ba.size(); ++i) chsum ^= ba.at(i);
//        ba.append(chsum);
//        if (m_mode == 0)
//        {
//            ba.prepend(static_cast<char>(FlagSerial));
//        } else
//        {
//            //
//        }
//        sendData(ba);

//        waitAns = true;
//        QTimer::singleShot(CheckTimeout, this, SLOT(verifyFlash()));
//        m_timer.start(AlarmTimeout);
//        return;
//    }

//    int blocksNum = m_firm.getBlocksNum();
//    static QByteArray dataBlock;
//    // Read Data & check
//    if (stg == DATA_READ)
//    {
//        if (waitAns)
//        {
//            if (m_data.size() < dataBlock.size() + 1) { QTimer::singleShot(CheckTimeout, this, SLOT(verifyFlash())); return; }

//            m_timer.stop();
//            quint8 ack = m_data.at(0);
//            if (ack != BootAnsOk) { errorHandler("Verify error"); return; }

//            m_data.remove(0, 1);
////            qDebug() << "RCV BLOCK: " << m_data.toHex();
////            qDebug() << "FW BLOCK: " << dataBlock.toHex();
//            if (m_data != dataBlock)
//            {
//                qDebug() << "RCV BLOCK: " << m_data.toHex();
//                qDebug() << "FW BLOCK: " << dataBlock.toHex();

//                errorHandler("Verify error");
//                return;
//            }

//            if (block > blocksNum)
//            {
//                waitAns = false;
//                block = 1;
//                stg = CMD_READ;
//                m_data.clear();
//                stageComplete();
//                return;
//            }

//            m_data.clear();
//            waitAns = false;
//            stg = CMD_READ;
//            QTimer::singleShot(1, this, SLOT(verifyFlash()));
//            return;
//        }

//        m_data.clear();
//        qDebug() << "Read block: " << block;
//        if (block % 10 == 0)
//        {
//            int percent = block * 100 / blocksNum;
//            m_strStatus = QString("Verify flash ... %1 %").arg(QString::number(percent));
//            emit strStatusChanged();
//        }

//        dataBlock = m_firm.getBlock(block);
//        QByteArray ba;
//        int size = dataBlock.size() - 1;
//        ba.prepend(size & 0xFF);
//        quint8 chsum = ba.at(0) ^ 0xFF;
//        ba.append(chsum);
//        ba.prepend(FlagSerial);
//        sendData(ba);

//        waitAns = true;
//        block++;
//        QTimer::singleShot(CheckTimeout, this, SLOT(verifyFlash()));
//        m_timer.start(AlarmTimeout);
//        return;
//    }
//}

////-----------------------------------------------------------------

//void FwUploader::goToWork()
//{
//    enum Stage { BOOT_TO_0, RST_TO_0, RST_TO_1, RESET_RST, RESET_BOOT };
//    static Stage stg = BOOT_TO_0;
//    static bool waitAns = false;

//    if (!m_conn.isConnected() || m_bError || reseting) { stg = BOOT_TO_0; waitAns = false; return; }

//    // Set Boot pin to 0 & check answer
//    if (stg == BOOT_TO_0)
//    {
//        if (waitAns)
//        {
//            if (m_data.isEmpty()) { QTimer::singleShot(CheckTimeout, this, SLOT(goToWork())); return; }

//            m_timer.stop();
//            if (m_mode == 0)
//            {
//                if (m_data.size() != 3) { errorHandler("Reset error"); return; }

//                quint8 cmd = m_data.at(0);
//                quint8 pin = m_data.at(1);
//                quint8 set = m_data.at(2);
//                if (cmd != EspCmdPin || pin != m_pinBoot || set != PinReset) { errorHandler("Reset error"); return; }
//            } else
//            {
//                if (m_data.size() != 3) { errorHandler("Reset error"); return; }
//                quint8 func = m_data.at(1);
//                quint8 attr = m_data.at(2);
//                if (func != NEspFuncCode || attr != NEspSetPinState) { errorHandler("Reset error"); return; }
//            }

//            m_data.clear();
//            waitAns = false;
//            stg = RST_TO_0;
//            QTimer::singleShot(100, this, SLOT(goToWork()));
//            return;
//        }

//        m_data.clear();
//        QByteArray ba;
//        if (m_mode == 0)
//        {
//            ba.append(static_cast<char>(FlagEsp));
//            ba.append(static_cast<char>(EspCmdPin));
//            ba.append(static_cast<char>(m_pinBoot));
//            ba.append(static_cast<char>(PinReset));
//        } else
//        {
//            ba.append(0x05);
//            ba.append(static_cast<char>(NEspFuncCode));
//            ba.append(static_cast<char>(NEspSetPinState));
//            ba.append(static_cast<char>(m_pinBoot));
//            ba.append(static_cast<char>(NEspPinStateReset));
//        }
//        sendData(ba);

//        waitAns = true;
//        QTimer::singleShot(100, this, SLOT(goToWork()));
//        m_timer.start(AlarmTimeout);
//        return;
//    }

//    // Set Reset pin to 0 & check answer
//    if (stg == RST_TO_0)
//    {
//        if (waitAns)
//        {
//            if (m_data.isEmpty()) { QTimer::singleShot(CheckTimeout, this, SLOT(goToWork())); return; }

//            m_timer.stop();
//            if (m_mode == 0)
//            {
//                if (m_data.size() != 3) { errorHandler("Reset error"); return; }
//                quint8 cmd = m_data.at(0);
//                quint8 pin = m_data.at(1);
//                quint8 set = m_data.at(2);
//                if (cmd != EspCmdPin || pin != m_pinRst || set != PinReset) { errorHandler("Reset error"); return; }
//            } else
//            {
//                if (m_data.size() != 3) { errorHandler("Reset error"); return; }
//                quint8 func = m_data.at(1);
//                quint8 attr = m_data.at(2);
//                if (func != NEspFuncCode || attr != NEspSetPinState) { errorHandler("Reset error"); return; }
//            }

//            m_data.clear();
//            waitAns = false;
//            stg = RST_TO_1;
//            QTimer::singleShot(100, this, SLOT(goToWork()));
//            return;
//        }

//        m_data.clear();
//        QByteArray ba;
//        if (m_mode == 0)
//        {
//            ba.append(static_cast<char>(FlagEsp));
//            ba.append(static_cast<char>(EspCmdPin));
//            ba.append(static_cast<char>(m_pinRst));
//            ba.append(static_cast<char>(PinReset));
//        } else
//        {
//            ba.append(0x05);
//            ba.append(static_cast<char>(NEspFuncCode));
//            ba.append(static_cast<char>(NEspSetPinState));
//            ba.append(static_cast<char>(m_pinRst));
//            ba.append(static_cast<char>(NEspPinStateReset));
//        }
//        sendData(ba);

//        waitAns = true;
//        QTimer::singleShot(100, this, SLOT(goToWork()));
//        m_timer.start(AlarmTimeout);
//        return;
//    }

//    // Set Reset pin to 1 & check answer
//    if (stg == RST_TO_1)
//    {
//        if (waitAns)
//        {
//            if (m_data.isEmpty()) { QTimer::singleShot(CheckTimeout, this, SLOT(goToWork())); return; }

//            m_timer.stop();
//            if (m_mode == 0)
//            {
//                if (m_data.size() != 3) { errorHandler("Reset error"); return; }

//                quint8 cmd = m_data.at(0);
//                quint8 pin = m_data.at(1);
//                quint8 set = m_data.at(2);
//                if (cmd != EspCmdPin || pin != m_pinRst || set != PinSet) { errorHandler("Reset error"); return; }
//            } else
//            {
//                if (m_data.size() != 3) { errorHandler("Reset error"); return; }
//                quint8 func = m_data.at(1);
//                quint8 attr = m_data.at(2);
//                if (func != NEspFuncCode || attr != NEspSetPinState) { errorHandler("Reset error"); return; }
//            }

//            m_data.clear();
//            waitAns = false;
//            stg = RESET_RST;
//            QTimer::singleShot(100, this, SLOT(goToWork()));
//            return;
//        }

//        m_data.clear();
//        QByteArray ba;
//        if (m_mode == 0)
//        {
//            ba.append(static_cast<char>(FlagEsp));
//            ba.append(static_cast<char>(EspCmdPin));
//            ba.append(static_cast<char>(m_pinRst));
//            ba.append(static_cast<char>(PinSet));
//        } else
//        {
//            ba.append(0x05);
//            ba.append(static_cast<char>(NEspFuncCode));
//            ba.append(static_cast<char>(NEspSetPinState));
//            ba.append(static_cast<char>(m_pinRst));
//            ba.append(static_cast<char>(NEspPinStateSet));
//        }
//        sendData(ba);

//        waitAns = true;
//        QTimer::singleShot(100, this, SLOT(goToWork()));
//        m_timer.start(AlarmTimeout);
//        return;
//    }

//    // Reset Rst pin mode to Input & check answer
//    if (stg == RESET_RST)
//    {
//        if (waitAns)
//        {
//            qDebug() << "Wait Ans RESET_RST";
//            if (m_data.isEmpty()) { QTimer::singleShot(CheckTimeout, this, SLOT(goToWork())); return; }

//            qDebug() << "Ans RESET_RST: " << m_data.toHex();
//            m_timer.stop();
//            if (m_mode == 0)
//            {
//                if (m_data.size() != 3) { errorHandler("Reset PIN error"); return; }

//                quint8 cmd = m_data.at(0);
//                quint8 pin = m_data.at(1);
//                quint8 mode = m_data.at(2);
//                if (cmd != EspCmdPinMode || pin != m_pinRst || mode != PinModeInput) { errorHandler("Reset PIN error"); return; }
//            } else
//            {
//                if (m_data.size() != 3) { errorHandler("Reset PIN error"); return; }
//                quint8 func = m_data.at(1);
//                quint8 attr = m_data.at(2);
//                if (func != NEspFuncCode || attr != NEspSetPinMode) { errorHandler("Reset PIN error"); return; }
//            }


//            m_data.clear();
//            waitAns = false;
//            stg = RESET_BOOT;
//            QTimer::singleShot(100, this, SLOT(goToWork()));
//            return;
//        }

//        m_data.clear();
//        QByteArray ba;
//        if (m_mode == 0)
//        {
//            ba.append(static_cast<char>(FlagEsp));
//            ba.append(static_cast<char>(EspCmdPinMode));
//            ba.append(static_cast<char>(m_pinRst));
//            ba.append(static_cast<char>(PinModeInput));
//        } else
//        {
//            ba.append(0x05);
//            ba.append(static_cast<char>(NEspFuncCode));
//            ba.append(static_cast<char>(NEspSetPinMode));
//            ba.append(static_cast<char>(m_pinRst));
//            ba.append(static_cast<char>(NEspPinModeInput));
//        }
//        sendData(ba);

//        waitAns = true;
//        QTimer::singleShot(100, this, SLOT(goToWork()));
//        m_timer.start(AlarmTimeout);
//        return;
//    }

//    // Reset Boot pin mode to Input & check answer
//    if (stg == RESET_BOOT)
//    {
//        if (waitAns)
//        {
//            qDebug() << "Wait Ans RESET_BOOT";
//            if (m_data.isEmpty()) { QTimer::singleShot(CheckTimeout, this, SLOT(goToWork())); return; }

//            qDebug() << "Ans RESET_BOOT: " << m_data.toHex();
//            m_timer.stop();
//            if (m_mode == 0)
//            {
//                if (m_data.size() != 3) { errorHandler("Reset PIN error"); return; }

//                quint8 cmd = static_cast<quint8>(m_data.at(0));
//                quint8 pin = m_data.at(1);
//                quint8 mode = m_data.at(2);
//                if (cmd != EspCmdPinMode || pin != m_pinBoot || mode != PinModeInput) { errorHandler("Reset PIN error"); return; }
//            } else
//            {
//                if (m_data.size() != 3) { errorHandler("Reset PIN error"); return; }
//                quint8 func = m_data.at(1);
//                quint8 attr = m_data.at(2);
//                if (func != NEspFuncCode || attr != NEspSetPinMode) { errorHandler("Reset PIN error"); return; }
//            }

//            // Finish goToWork stage
//            m_data.clear();
//            waitAns = false;
//            stg = BOOT_TO_0;
//            stageComplete();
//            return;
//        }

//        m_data.clear();
//        QByteArray ba;
//        if (m_mode == 0)
//        {
//            ba.append(static_cast<char>(FlagEsp));
//            ba.append(static_cast<char>(EspCmdPinMode));
//            ba.append(static_cast<char>(m_pinBoot));
//            ba.append(static_cast<char>(PinModeInput));
//        } else
//        {
//            ba.append(0x05);
//            ba.append(static_cast<char>(NEspFuncCode));
//            ba.append(static_cast<char>(NEspSetPinMode));
//            ba.append(static_cast<char>(m_pinBoot));
//            ba.append(static_cast<char>(NEspPinModeInput));
//        }
//        sendData(ba);

//        waitAns = true;
//        QTimer::singleShot(100, this, SLOT(goToWork()));
//        m_timer.start(AlarmTimeout);
//        return;
//    }
//}

////-----------------------------------------------------------------

//void FwUploader::sendData(const QByteArray &data)
//{
//    if (m_mode == 0) m_conn.setActiveLevel2(0);
//        else m_conn.setActiveLevel2(2);
//    m_conn.sendData(data);
//}

////-----------------------------------------------------------------

//void FwUploader::setVerification(bool verif)
//{
//    qDebug() << "FwUploader::setVerification: " << verif;
//    m_bVerify = verif;
//    emit verificationChanged();
//}

////-----------------------------------------------------------------

//void FwUploader::resetDevice()
//{
//    // QTest::qWait(500);
//    if (!m_conn.isConnected() || m_bUploading) return;

//    // Set Rst pin as output
//    QByteArray ba;
//    ba.append(FlagEsp);
//    ba.append(EspCmdPinMode);
//    ba.append(m_pinRst);
//    ba.append(PinModeOutput);
//    ba.append(PinSet);
//    sendData(ba);
////    QTest::qWait(300);

//    // Rst pin to 0
//    ba.clear();
//    ba.append(FlagEsp);
//    ba.append(EspCmdPin);
//    ba.append(m_pinRst);
//    ba.append(PinReset);
//    sendData(ba);
////    QTest::qWait(500);

//    // Rst pin to 1
//    ba.clear();
//    ba.append(FlagEsp);
//    ba.append(EspCmdPin);
//    ba.append(m_pinRst);
//    ba.append(PinSet);
//    sendData(ba);
////    QTest::qWait(500);

//    // Set Rst pin as input
//    ba.clear();
//    ba.append(FlagEsp);
//    ba.append(EspCmdPinMode);
//    ba.append(m_pinRst);
//    ba.append(PinModeInput);
//    sendData(ba);
//}

////-----------------------------------------------------------------


//}    // namespace load


