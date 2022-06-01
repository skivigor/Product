#ifndef TESTCONFIGLOADER_H
#define TESTCONFIGLOADER_H

#include <QObject>
#include "iconfigloader.h"

#include <QTimer>


namespace config
{

class TestConfigLoader : public QObject
{
    Q_OBJECT

    enum TestStage
    {
        StageInit,
        StageChapterVariantList,
        StageChapterJsonDoc,
        StageVariant,
        StageJsonDoc
    };

private:
    IConfigLoader &m_config;
    TestStage m_stage;

    int m_pause;
    QTimer m_timer;

private:
    TestConfigLoader(const TestConfigLoader&);
    TestConfigLoader& operator=(const TestConfigLoader&);

private slots:
    void processing();
    void onConfigUpdated();

public:
    explicit TestConfigLoader(IConfigLoader &config, QObject *parent = 0);
    ~TestConfigLoader();

    void start();
    void stop();

signals:

public slots:
};


}    // namespace config


#endif // TESTCONFIGLOADER_H
