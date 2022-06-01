#ifndef AVLOG_H
#define AVLOG_H

#include <QObject>
#include <QFile>
#include <QTime>
#include <QVariantList>

namespace avlog
{

struct AvLogConfig
{
    QString  Prefix;
    bool     SaveFile;
    bool     ShowFunc;
    bool     ShowFileName;
    bool     ClientMode;

    explicit AvLogConfig(const QString &pref = "AvLog-",
                         bool save = false,
                         bool showFunc = true,
                         bool showFileName = true,
                         bool clientMode = false)
        : Prefix(pref),
          SaveFile(save),
          ShowFunc(showFunc),
          ShowFileName(showFileName),
          ClientMode(clientMode) {}
};

class AvLog : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString mesDebug READ getMesDebug NOTIFY mesDebugChanged)
    Q_PROPERTY(QString mesWarn READ getMesWarn NOTIFY mesWarnChanged)
    Q_PROPERTY(QString mesInfo READ getMesInfo NOTIFY mesInfoChanged)
    Q_PROPERTY(QString mesCritical READ getMesCritical NOTIFY mesCriticalChanged)

    Q_PROPERTY(QString mesProduct READ getMesProduct NOTIFY mesProductChanged)
    Q_PROPERTY(QVariantList transparant READ getTransparant NOTIFY transparantChanged)

private:
    AvLogConfig  m_cfg;
    QFile        m_file;
    QDate        m_date;

    QString  m_mesDebug;
    QString  m_mesWarn;
    QString  m_mesInfo;
    QString  m_mesCritical;
    QString  m_mesProduct;    // not saved to log file
    QVariantList m_transparant;

private:
    void openLogFile();
    void closeLogFile();
    void print(const QString &mes);

private:
    explicit AvLog(const AvLogConfig &cfg, QObject *parent = nullptr);
    ~AvLog();
    AvLog(const AvLog&);
    AvLog& operator=(const AvLog&);

public:
    static AvLog& instance(const AvLogConfig &cfg = AvLogConfig());
    static void messageHandler(QtMsgType type, const QMessageLogContext &context, const QString &msg);
    void log(const QString &mes);

signals:
    void mesDebugChanged();
    void mesWarnChanged();
    void mesInfoChanged();
    void mesCriticalChanged();
    void mesProductChanged();
    void transparantChanged();

public slots:
    QString getMesDebug() const         { return m_mesDebug; }
    QString getMesWarn() const          { return m_mesWarn; }
    QString getMesInfo() const          { return m_mesInfo; }
    QString getMesCritical() const      { return m_mesCritical; }
    QString getMesProduct() const       { return m_mesProduct; }
    QVariantList getTransparant() const { return m_transparant; }

    void show(const QString &color, const QString &mes);    // for product messages
    void show(const QString &color, const QString &mes, bool busy, bool blink);    // for product messages

    void saveSettings(const QString &key, const QJsonObject &set) const;
    void saveSettings(const QString &key, const QString &set) const;
};


}    // namespace avlog


#endif // AVLOG_H
