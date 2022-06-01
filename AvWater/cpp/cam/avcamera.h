#ifndef AVCAMERA_H
#define AVCAMERA_H

#include <QObject>
#include <QCamera>
#include <QCameraImageCapture>

namespace cam
{

class AvCamera : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool ready READ isReady NOTIFY readyChanged)
    Q_PROPERTY(QString imagePath READ getImagePath NOTIFY imagePathChanged)

private:
    QCamera             *m_pCamera = nullptr;
    QCameraImageCapture *m_pImageCapture = nullptr;
    bool                 m_ready = false;
    QString              m_imagePath = "";

private slots:
    //    void processCapturedImage(int requestId, const QImage &img);
    void readyForCapture(bool ready);
    void imageSaved(int id, const QString &fileName);

public:
    explicit AvCamera(QObject *parent = nullptr);
    ~AvCamera();

signals:
    void readyChanged();
    void imagePathChanged();

public slots:
    bool isReady() const         { return m_ready; }
    QString getImagePath() const { return m_imagePath; }

    void screenshot(const QString &path);



};


}    // namespace cam


#endif // AVCAMERA_H
