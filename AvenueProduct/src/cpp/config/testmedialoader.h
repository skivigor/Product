#ifndef TESTMEDIALOADER_H
#define TESTMEDIALOADER_H

#include <QObject>
#include "imedialoader.h"

#include <QTimer>


namespace config
{

class TestMediaLoader : public QObject
{
    Q_OBJECT

    enum TestStage
    {
        StageInit,
        StageNames,
        StageInfoJson,
        StageElement
    };

private:
    IMediaLoader &m_media;
    TestStage m_stage;

    int m_pause;
    QTimer m_timer;

private:
    TestMediaLoader(const TestMediaLoader&);
    TestMediaLoader& operator=(const TestMediaLoader&);

private slots:
    void processing();
    void onMediaUpdated();

public:
    explicit TestMediaLoader(IMediaLoader &media, QObject *parent = 0);
    ~TestMediaLoader();

    void start();
    void stop();

signals:

public slots:
};


}    // namespace config


#endif // TESTMEDIALOADER_H
