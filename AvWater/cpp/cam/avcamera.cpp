#include "avcamera.h"
#include <QCameraInfo>

#include <QDebug>

namespace cam
{

AvCamera::AvCamera(QObject *parent)
{
    Q_UNUSED(parent)

    const QList<QCameraInfo> availableCameras = QCameraInfo::availableCameras();
    for (const QCameraInfo &cameraInfo : availableCameras)
    {
        qDebug() << "INFO: " << cameraInfo.deviceName() << " : " << cameraInfo.description();

        if (cameraInfo == QCameraInfo::defaultCamera()) qDebug() << "!!!!! Default " << cameraInfo.position();
    }

//    QImageEncoderSettings settings = imagecapture->encodingSettings();
//    settings.setCodec(boxValue(ui->imageCodecBox).toString());
//    settings.setQuality(QMultimedia::EncodingQuality(ui->imageQualitySlider->value()));
//    settings.setResolution(boxValue(ui->imageResolutionBox).toSize());

    QCameraInfo def = QCameraInfo::defaultCamera();
    if (def.isNull()) return;

    m_pCamera = new QCamera(def);
    m_pCamera->setCaptureMode(QCamera::CaptureStillImage);
    m_pImageCapture = new QCameraImageCapture(m_pCamera);

    connect(m_pImageCapture, &QCameraImageCapture::readyForCaptureChanged, this, &AvCamera::readyForCapture);
//    connect(m_pImageCapture, &QCameraImageCapture::imageCaptured, this, &AvCamera::processCapturedImage);
    connect(m_pImageCapture, &QCameraImageCapture::imageSaved, this, &AvCamera::imageSaved);

    m_pCamera->start();

}

AvCamera::~AvCamera()
{
    if (m_pImageCapture != nullptr) { m_pCamera->stop(); delete m_pImageCapture; }
    if (m_pCamera != nullptr) delete m_pCamera;
}

//-----------------------------------------------------------------

void AvCamera::readyForCapture(bool ready)
{
    qDebug() << "AvCamera::readyForCapture: " << ready;
    m_ready = ready;
    emit readyChanged();
}

//-----------------------------------------------------------------

void AvCamera::imageSaved(int id, const QString &fileName)
{
    Q_UNUSED(id)
    qDebug() << "AvCamera::imageSaved: " << fileName;

    m_imagePath = fileName;
    emit imagePathChanged();
}


//-----------------------------------------------------------------

void AvCamera::screenshot(const QString &path)
{
    if (m_ready == false) return;
    m_pImageCapture->capture(path);
}

//-----------------------------------------------------------------

//void AvCamera::processCapturedImage(int requestId, const QImage &img)
//{
//    qDebug() << "AvCamera::processCapturedImage";
//}

//-----------------------------------------------------------------


}    // namespace cam

