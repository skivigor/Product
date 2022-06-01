#include "fwmodel.h"
#include "util/fileloader.h"

#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

#include <QTest>
#include <QDebug>
#include "assert.h"

namespace stand
{

FwModel::FwModel(QObject *parent)
    : m_pLink(nullptr),
      m_idx(-1)
{
    Q_UNUSED(parent);
}

FwModel::~FwModel()
{
}

//-----------------------------------------------------------------

int FwModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_modelList.size();
}

//-----------------------------------------------------------------

QHash<int, QByteArray> FwModel::roleNames() const
{
    QHash<int, QByteArray> roles;

    roles[DescrRole] = "descr";
    roles[FNameRole] = "binname";
    roles[FSizeRole] = "binsize";
    roles[CheckStateRole] = "checkState";
    roles[LoadStateRole] = "loadState";
    roles[CheckStatusRole] = "checkStatus";
    roles[LoadStatusRole] = "loadStatus";
    return roles;
}

//-----------------------------------------------------------------

void FwModel::onChanged()
{
    FwLoader *ptr = qobject_cast<FwLoader *>(QObject::sender());

    for (int i = 0; i < m_modelList.size(); i++)
    {
        if (ptr == m_modelList.at(i).data())
        {
            emit dataChanged(index(i), index(i));
            return;
        }
    }
}

//-----------------------------------------------------------------

void FwModel::onChecked()
{
    FwLoader *ptr = qobject_cast<FwLoader *>(QObject::sender());
    assert(ptr);
    qDebug() << "FwModel::onChecked: fw: " << ptr->getDescription();
    ptr->setLink(nullptr);

    m_idx++;
    if (m_idx >= m_modelList.size())
    {
        m_idx = -1;
        emit checked();
        return;
    }
    m_modelList.at(m_idx)->setLink(m_pLink);
    m_modelList.at(m_idx)->check();
}

//-----------------------------------------------------------------

void FwModel::onLoaded()
{
    FwLoader *ptr = qobject_cast<FwLoader *>(QObject::sender());
    assert(ptr);
    qDebug() << "FwModel::onLoaded: fw: " << ptr->getDescription();
    ptr->setLink(nullptr);

    m_idx++;
    if (m_idx >= m_modelList.size())
    {
        m_idx = -1;
        emit loaded();
        return;
    }
    QTest::qWait(2000);
    m_modelList.at(m_idx)->setLink(m_pLink);
    m_modelList.at(m_idx)->load();
}

//-----------------------------------------------------------------

void FwModel::onError()
{
    FwLoader *ptr = qobject_cast<FwLoader *>(QObject::sender());
    assert(ptr);
    emit error();
    m_idx = -1;
    qDebug() << "FwModel::onError: fw: " << ptr->getDescription();
}

//-----------------------------------------------------------------

QVariant FwModel::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() > m_modelList.size()) return QVariant();

    QSharedPointer<FwLoader> ptr = m_modelList[index.row()];

    if (role == DescrRole) return ptr->getDescription();
    if (role == FNameRole) return ptr->getFwName();
    if (role == FSizeRole) return ptr->getFwSize();
    if (role == CheckStateRole) return ptr->getCheckState();
    if (role == LoadStateRole) return ptr->getLoadState();
    if (role == CheckStatusRole) return ptr->getCheckStatus();
    if (role == LoadStatusRole) return ptr->getLoadStatus();

    return QVariant();
}

//-----------------------------------------------------------------

void FwModel::setLink(trans::SerialClient *ptr)
{
    m_pLink = ptr;
}

//-----------------------------------------------------------------

void FwModel::reload(const QString &cfgPath, const QString &fwPath)
{
    clear();
//    qDebug() << "FwModel::reload: " << cfgPath << " " << fwPath;

    QJsonDocument doc = util::FileLoader::instance().getFileAsJsonDoc(cfgPath);
    if (doc.isEmpty())
    {
        qWarning() << "FwModel::reload: config empty: " << cfgPath;
        return;
    }

    QJsonObject jObj = doc.object();
    assert(jObj["firmware"].isArray());
    QJsonArray jArr = jObj["firmware"].toArray();

    QSharedPointer<FwLoader> ptr;

    for (int i = 0; i < jArr.size(); ++i)
    {
        QJsonObject obj = jArr.at(i).toObject();
        ptr = QSharedPointer<FwLoader>(new FwLoader(obj, fwPath));
        assert(!ptr.isNull());
        addItem(ptr);
        ptr.clear();
    }
}

//-----------------------------------------------------------------

void FwModel::addItem(QSharedPointer<FwLoader> ptr)
{
    beginInsertRows(QModelIndex(), rowCount(), rowCount());
    m_modelList << ptr;
    QObject::connect(ptr.data(), SIGNAL(changed()), this, SLOT(onChanged()));
    QObject::connect(ptr.data(), SIGNAL(checked()), this, SLOT(onChecked()));
    QObject::connect(ptr.data(), SIGNAL(loaded()), this, SLOT(onLoaded()));
    QObject::connect(ptr.data(), SIGNAL(error()), this, SLOT(onError()));
    endInsertRows();
}

//-----------------------------------------------------------------

void FwModel::addItem(const QJsonObject &cfg, const QString &fileName, const QByteArray &fw)
{
    QSharedPointer<FwLoader> ptr = QSharedPointer<FwLoader>(new FwLoader(cfg, fileName, fw));
    assert(!ptr.isNull());
    addItem(ptr);
}

//-----------------------------------------------------------------

void FwModel::clear()
{
    if (m_modelList.isEmpty()) return;

    beginRemoveRows(QModelIndex(), 0, m_modelList.size() - 1);
    m_modelList.clear();
    endRemoveRows();
}

//-----------------------------------------------------------------

void FwModel::checkFw()
{
    if (m_idx != -1 || !m_modelList.size() || !m_pLink) return;

    m_idx = 0;
    m_modelList.at(m_idx)->setLink(m_pLink);
    m_modelList.at(m_idx)->check();
}

//-----------------------------------------------------------------

void FwModel::loadFw()
{
    if (m_idx != -1 || !m_modelList.size() || !m_pLink) return;

    m_idx = 0;
    m_modelList.at(m_idx)->setLink(m_pLink);
    m_modelList.at(m_idx)->load();
}

//-----------------------------------------------------------------

void FwModel::resetCheckStatus()
{
    for (int i = 0; i < m_modelList.size(); ++i) m_modelList.at(i)->resetCheckStatus();
}

//-----------------------------------------------------------------

void FwModel::resetLoadStatus()
{
    for (int i = 0; i < m_modelList.size(); ++i) m_modelList.at(i)->resetLoadStatus();
}

//-----------------------------------------------------------------

}    // namespace stand

