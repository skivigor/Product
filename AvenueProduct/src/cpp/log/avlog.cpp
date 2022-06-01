#include "avlog.h"

#include <QDir>
#include <QCoreApplication>
#include <QtDebug>

#include <QJsonDocument>
#include <QJsonObject>

namespace avlog
{

AvLog::AvLog(const AvLogConfig &cfg, QObject *parent)
    : m_cfg(cfg)
{
    Q_UNUSED(parent)
    m_transparant << "black" << "" << false << false;

    QDir dir(QCoreApplication::applicationDirPath() + "/log");
    if (!dir.exists()) dir.mkpath(".");
}

AvLog::~AvLog()
{
    closeLogFile();
}

//-----------------------------------------------------------------

AvLog &AvLog::instance(const AvLogConfig &cfg)
{
    static AvLog log(cfg);
    return log;
}

//-----------------------------------------------------------------

void AvLog::openLogFile()
{
    if (m_file.isOpen()) return;
    m_file.setFileName(QCoreApplication::applicationDirPath() + "/log/" + m_cfg.Prefix + QDate::currentDate().toString("ddMMyyyy") + ".txt");
    m_file.open(QIODevice::WriteOnly | QIODevice::Append);
}

//-----------------------------------------------------------------

void AvLog::closeLogFile()
{
    if (!m_file.isOpen()) return;
    m_file.flush();
    m_file.close();
}

//-----------------------------------------------------------------

void AvLog::print(const QString &mes)
{
    if (mes.isEmpty()) return;

    // Console output
    QString time = QTime::currentTime().toString("hh:mm:ss.zzz   ");

    if (m_cfg.ClientMode) fprintf(stdout, "#####%s", qPrintable(mes));
        else fprintf(stdout, "%s %s \n", qPrintable(time), qPrintable(mes));
    fflush(stdout);

    // Log file output
    if (!m_cfg.SaveFile) return;
    QDate date = QDate::currentDate();

    if (date == m_date)
    {
        if (!m_file.isOpen()) openLogFile();
    } else
    {
        closeLogFile();
        openLogFile();
        m_date = date;
    }

    QTextStream ts(&m_file);
    ts << time << mes << endl;
}

//-----------------------------------------------------------------

void AvLog::log(const QString &mes)
{
    if (mes.isEmpty()) return;

    QStringList type({ "INFO", "WARNING", "CRITICAL", "DEBUG" });
    const QString separator("<br>---------------------------------------------------------------------------");
//    const QString separator("<hr width=\"300\">");

    QStringList l = mes.split("#####");
    for (int i = 0; i < l.size(); ++i)
    {
        QString m = l.at(i);
        QStringList list = m.split(":");
        QString s = QTime::currentTime().toString("hh:mm:ss.zzz   ") + m;

        if (list.at(0) == type.at(0))
        {
            static int count = 0;
            const QString style1("<div style=\"background:#6600CC00; margin-top:2;\">");
            const QString style2("<div style=\"background:#2200CC00; margin-top:2;\">");
            const QString endStyle("</div>");

            if (count % 2 == 0) m_mesInfo += style1 + s + endStyle;
                else m_mesInfo += style2 + s + endStyle;
            count++;
            m_mesInfo += separator;

            m_mesDebug += style1 + s + endStyle;
            m_mesDebug += separator;
            emit mesInfoChanged();
        }
        if (list.at(0) == type.at(1))
        {
            static int count = 0;
            const QString style1("<div style=\"background:#66FF9900; margin-top:2;\">");
            const QString style2("<div style=\"background:#22FF9900; margin-top:2;\">");
            const QString endStyle("</dev>");

            if (count % 2 == 0) m_mesWarn += style1 + s + endStyle;
                else m_mesWarn += style2 + s + endStyle;
            count++;
            m_mesWarn += separator;

            m_mesDebug += style1 + s + endStyle;
            m_mesDebug += separator;
            emit mesWarnChanged();
        }
        if (list.at(0) == type.at(2))
        {
            static int count = 0;
            const QString style1("<div style=\"background:#66FF3300; margin-top:2;\">");
            const QString style2("<div style=\"background:#66FF3300; margin-top:2;\">");
            const QString endStyle("</dev>");

            if (count % 2 == 0) m_mesCritical += style1 + s + endStyle;
                else m_mesCritical += style2 + s + endStyle;
            count++;
            m_mesCritical += separator;

            m_mesDebug += style1 + s + endStyle;
            m_mesDebug += separator;
            emit mesCriticalChanged();
        }
        if (list.at(0) == type.at(3))
        {
            const QString style("<div style=\"background:#88d0d0d0; margin-top:2;\">");
            const QString endStyle("</dev>");

            m_mesDebug += style + s + endStyle;
            m_mesDebug += separator;
        }

        emit mesDebugChanged();
        print(m);
    }
}

//-----------------------------------------------------------------

void AvLog::show(const QString &color, const QString &mes)
{
    QString t = QTime::currentTime().toString("hh:mm:ss.zzz");
    QString s = QString("%1 | <font color=\"%2\">%3</font><br>").arg(t).arg(color).arg(mes);
    m_mesProduct += s;
    emit mesProductChanged();

    // <font color="цвет">...</font>
}

//-----------------------------------------------------------------

void AvLog::show(const QString &color, const QString &mes, bool busy, bool blink)
{
//    qDebug() << "AvLog::show2: " << mes << " " << busy << " " << blink;
    show(color, mes);
    m_transparant.clear();
    m_transparant << color << mes << busy << blink;
    emit transparantChanged();
}

//-----------------------------------------------------------------

void AvLog::saveSettings(const QString &key, const QJsonObject &set) const
{
    QJsonDocument doc(set);
    QString strJson(doc.toJson(QJsonDocument::Compact));
    saveSettings(key, strJson);
}

//-----------------------------------------------------------------

void AvLog::saveSettings(const QString &key, const QString &set) const
{
    QFile file;
    file.setFileName(QCoreApplication::applicationDirPath() + "/log/" + "AvSet_" + QDate::currentDate().toString("ddMMyyyy") + ".txt");
    if (!file.open(QIODevice::WriteOnly | QIODevice::Append)) return;

    QString time = QTime::currentTime().toString("hh:mm:ss.zzz");
    QTextStream ts(&file);
    ts << time << " :: " << key << " :: " << set << endl;

    file.flush();
    file.close();
}

//-----------------------------------------------------------------

void AvLog::messageHandler(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
    QHash<QtMsgType, QString> msgLevelHash({ {QtDebugMsg, "DEBUG"}, {QtInfoMsg, "INFO"}, {QtWarningMsg, "WARNING"}, {QtCriticalMsg, "CRITICAL"}, {QtFatalMsg, "FATAL"} });
    QByteArray localMsg = msg.toLocal8Bit();
    QString logLevelName = msgLevelHash[type];
    QByteArray logLevelMsg = logLevelName.toLocal8Bit();

    QString s = QString("%1:  %2").arg(logLevelName, msg);
    if (instance().m_cfg.ShowFunc) s.append(QString("   [ %1 ]").arg(context.function));
    if (instance().m_cfg.ShowFileName) s.append(QString("   (%1 : Line %2)").arg(context.file).arg(context.line));
    instance().log(s);

    if (type == QtFatalMsg)
        abort();
}

//-----------------------------------------------------------------

//    QString txt = QString("%1 %2: %3 (%4)").arg(formattedTime, logLevelName, msg, context.file);
//    QString txt = QString("%1: %2 (%3)").arg(logLevelName, msg, context.file);

//    fprintf(stdout, "%s %s: %s (%s:%u, %s)\n", formattedTimeMsg.constData(), logLevelMsg.constData(), localMsg.constData(), context.file, context.line, context.function);
//    fflush(stdout);



}    // namespace avlog

