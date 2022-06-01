#include "utiltool.h"
#include <QTime>
#include <QGuiApplication>

namespace util
{

UtilTool::UtilTool(QObject *parent)
{
    Q_UNUSED(parent)
}

UtilTool::~UtilTool()
{
}

//-----------------------------------------------------------------

void UtilTool::wait(int ms) const
{
    QTime dieTime = QTime::currentTime().addMSecs(ms);
    while (QTime::currentTime() < dieTime)
    {
        QCoreApplication::processEvents(QEventLoop::AllEvents, 100);
    }
}

//-----------------------------------------------------------------


}   // namespace util

