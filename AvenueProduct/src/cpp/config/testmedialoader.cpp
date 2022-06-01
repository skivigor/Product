#include "testmedialoader.h"

#include <QString>
#include <QStringList>
#include <QByteArray>
#include <QJsonDocument>

#include <QDebug>
#include "assert.h"


namespace config
{

TestMediaLoader::TestMediaLoader(IMediaLoader &media, QObject *parent)
    : m_media(media),
      m_stage(TestStage::StageInit),
      m_pause(200)
{
    Q_UNUSED(parent);

    QObject::connect(dynamic_cast<QObject *>(&m_media), SIGNAL(mediaChanged()),
                     this, SLOT(onMediaUpdated()), Qt::QueuedConnection);

    QObject::connect(&m_timer, SIGNAL(timeout()), this, SLOT(processing()), Qt::QueuedConnection);

}

TestMediaLoader::~TestMediaLoader()
{
}


//--------------- private ----------------------------

void TestMediaLoader::processing()
{
    qDebug() << "           PROCESSING MEDIA TEST in stage: " << m_stage;

    if (m_stage == TestStage::StageInit)
    {
        QByteArray ba = m_media.getHash();
        assert(!ba.isEmpty());
        qDebug() << "HASH of MEDIA: " << ba.toHex();

        m_stage = TestStage::StageNames;
        return;
    }

    if (m_stage == TestStage::StageNames)
    {
        qDebug() << "MEDIA NAMES";
        QStringList names = m_media.getNames();
        assert(names.size() > 0);
        for (int i = 0; i < names.size(); i++) qDebug() << names.at(i);

        m_stage = TestStage::StageInfoJson;
        return;
    }

    if (m_stage == TestStage::StageInfoJson)
    {
        qDebug() << "MEDIA JSON INFO";
        QJsonDocument doc = m_media.getInfoAsJson();
        assert(!doc.isEmpty());
        qDebug() << doc;

        m_stage = TestStage::StageElement;
        return;
    }

    if (m_stage == TestStage::StageElement)
    {
        qDebug() << "MEDIA STAGE ELEMENT";
        QStringList names = m_media.getNames();
        assert(names.size() > 0);
        QByteArray ba;
        for (int i = 0; i < names.size(); i++)
        {
            ba = m_media.getElement(names.at(i));
            assert(ba.size() > 0);

            qDebug() << "Element size: " << ba.size();
        }

        m_stage = TestStage::StageInit;
        return;
    }

    assert(0);
}

//----------------------------------------------------

void TestMediaLoader::onMediaUpdated()
{
    qDebug() << "RECEIVE SIGNAL MEDIA UPDATED";

    if (m_timer.isActive()) m_timer.stop();

    m_stage = TestStage::StageInit;
    start();
}


//--------------- public ----------------------------

void TestMediaLoader::start()
{
    qDebug() << "START MEDIA TEST";

    if (m_timer.isActive()) return;

    m_timer.start(m_pause);
}

//----------------------------------------------------

void TestMediaLoader::stop()
{
    if (!m_timer.isActive()) return;

    m_timer.stop();
}


}    // namespace config


