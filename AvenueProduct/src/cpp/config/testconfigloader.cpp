#include "testconfigloader.h"

#include <QByteArray>
#include <QVariantList>
#include <QJsonDocument>

#include <QDebug>
#include <assert.h>


namespace config
{

TestConfigLoader::TestConfigLoader(IConfigLoader &config, QObject *parent)
    : m_config(config),
      m_stage(TestStage::StageInit),
      m_pause(100)
{
    Q_UNUSED(parent);

    QObject::connect(dynamic_cast<QObject *>(&m_config), SIGNAL(configChanged()),
                     this, SLOT(onConfigUpdated()), Qt::QueuedConnection);

    QObject::connect(&m_timer, SIGNAL(timeout()), this, SLOT(processing()), Qt::QueuedConnection);

}

TestConfigLoader::~TestConfigLoader()
{
}


//--------------- private ----------------------------

void TestConfigLoader::processing()
{
    qDebug() << "           PROCESSING CONFIG TEST in stage: " << m_stage;

    if (m_stage == TestStage::StageInit)
    {
        QByteArray ba = m_config.getHash();
        assert(!ba.isEmpty());
        qDebug() << "HASH of config: " << ba.toHex();

        m_stage = TestStage::StageChapterVariantList;
        return;
    }

    if (m_stage == TestStage::StageChapterVariantList)
    {
        qDebug() << "CHAPTER AS VARIANTLIST";
        QVariantList list = m_config.getChapterAsVariantList(DataType::CFG_ARRAY, "addr");
        assert(list.size() > 0);
        qDebug() << list;

        m_stage = TestStage::StageChapterJsonDoc;
        return;
    }

    if (m_stage == TestStage::StageChapterJsonDoc)
    {
        qDebug() << "CHAPTER AS JSON DOCUMENT";
        QJsonDocument doc = m_config.getChapterAsJsonDoc(DataType::CFG_ARRAY, "addr");
        assert(!doc.isEmpty());
        qDebug() << doc;

        m_stage = TestStage::StageVariant;
        return;
    }

    if (m_stage == TestStage::StageVariant)
    {
        qDebug() << "FULL CONFIG AS VARIANT";
        QVariant cfg = m_config.getAsVariant();
        assert(!cfg.isNull());
        qDebug() << cfg;

        m_stage = TestStage::StageJsonDoc;
        return;
    }

    if (m_stage == TestStage::StageJsonDoc)
    {
        qDebug() << "CONFIG AS JSON DOCUMENT";
        QJsonDocument doc = m_config.getAsJsonDoc();
        assert(!doc.isEmpty());
        qDebug() << doc;

        m_stage = TestStage::StageInit;
        return;
    }

    assert(0);
}

//----------------------------------------------------

void TestConfigLoader::onConfigUpdated()
{
    qDebug() << "RECEIVE SIGNAL CONFIG UPDATED";

    if (m_timer.isActive()) m_timer.stop();

    m_stage = TestStage::StageInit;
    start();
}


//--------------- public ----------------------------

void TestConfigLoader::start()
{
    qDebug() << "START CONFIG TEST";

    if (m_timer.isActive()) return;

    m_timer.start(m_pause);
}

//----------------------------------------------------

void TestConfigLoader::stop()
{
    if (!m_timer.isActive()) return;

    m_timer.stop();
}


}    // namespace config


