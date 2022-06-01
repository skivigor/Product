//#ifndef FWUPLOADER_H
//#define FWUPLOADER_H

//#include <QObject>
//#include <QByteArray>
//#include <QString>
//#include <QTimer>

//namespace trans
//{
//class Connection;
//}    // namespace trans

//namespace load
//{
//class Firmware;

//class FwUploader : public QObject
//{
//    Q_OBJECT
//    Q_PROPERTY(QString strStatus READ getStrStatus NOTIFY strStatusChanged)
//    Q_PROPERTY(bool error READ isErrored NOTIFY errorChanged)
//    Q_PROPERTY(bool uploading READ isUploading NOTIFY uploadingChanged)
//    Q_PROPERTY(bool verify READ getVerification WRITE setVerification NOTIFY verificationChanged)

//private:
//    enum UpStage
//    {
//        STAGE_IDLE,
//        STAGE_BOOT,
//        STAGE_ERASE,
//        STAGE_WRITE,
//        STAGE_VERIF
//    };

//private:
//    trans::Connection  &m_conn;
//    Firmware       &m_firm;
//    int             m_mode;
//    quint8          m_pinBoot;
//    quint8          m_pinRst;
//    QByteArray      m_data;

//    UpStage         m_stage;
//    QString         m_strStatus;
//    bool            m_bError;
//    bool            m_bUploading;
//    bool            m_bVerify;

//    QTimer          m_timer;

//private:
//    FwUploader(const FwUploader&);
//    FwUploader& operator=(const FwUploader&);

//private slots:
//    void onRcvData(QByteArray data);
//    void onTimeout();
//    void stageComplete();
//    void resetStages();
//    void errorHandler(const QString &status);

//    void goToBoot();
//    void eraseFlash();
//    void writeFlash();
//    void verifyFlash();
//    void goToWork();

//    void sendData(const QByteArray &data);


//public:
//    explicit FwUploader(trans::Connection &conn, Firmware &firm, quint8 pinBoot, quint8 pinRst, QObject *parent = nullptr);
//    ~FwUploader();

//signals:
//    void strStatusChanged();
//    void errorChanged();
//    void uploadingChanged();
//    void verificationChanged();

//public slots:
//    void uploadFirmware();
//    QString getStrStatus() const   { return m_strStatus; }
//    bool isErrored() const         { return m_bError; }
//    bool isUploading() const       { return m_bUploading; }
//    bool getVerification() const   { return m_bVerify; }
//    void setVerification(bool verif);

//    void resetDevice();

//    void setMode(int mode)   { m_mode = mode; }

//};


//}    // namespace load


//#endif // FWUPLOADER_H
