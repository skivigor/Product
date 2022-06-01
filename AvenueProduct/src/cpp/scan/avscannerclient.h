#ifndef AVSCANNERCLIENT_H
#define AVSCANNERCLIENT_H

#include <QObject>
#include <QProcess>

namespace scan
{

class AvScannerClient : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString scandata READ getData NOTIFY dataChanged)
    Q_PROPERTY(bool openned READ isOpenned NOTIFY opennedChanged)

private:
    QProcess *m_proc;
    QString   m_data;
    bool      m_openned;

private slots:
    void onStarted();
    void onReadyReadStandardOutput();
    void onErrorOccurred(QProcess::ProcessError error);
    void onFinished(int exitCode, QProcess::ExitStatus exitStatus);

public:
    explicit AvScannerClient(QObject *parent = nullptr);
    ~AvScannerClient();

signals:
    void dataChanged();
    void opennedChanged();

public slots:
    void open();
    bool isOpenned() const   { return m_openned; }
    QString getData();
    void clearData();
    void close();
};


}    // namespace scan


#endif // AVSCANNERCLIENT_H
