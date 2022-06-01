#ifndef FWMODEL_H
#define FWMODEL_H

#include <QAbstractListModel>
#include <QList>
#include <QVariant>
#include <QModelIndex>
#include <QSharedPointer>

#include "fwloader.h"
#include "trans/serialclient.h"

namespace stand
{

class FwModel : public QAbstractListModel
{
    Q_OBJECT

private:
    enum ModelRoles
    {
        DescrRole = Qt::UserRole + 11,
        FNameRole = Qt::UserRole + 12,
        FSizeRole = Qt::UserRole + 13,
        CheckStateRole = Qt::UserRole + 14,
        LoadStateRole = Qt::UserRole + 15,
        CheckStatusRole = Qt::UserRole + 16,
        LoadStatusRole = Qt::UserRole + 17
    };

private:
    trans::SerialClient *m_pLink;
    QList<QSharedPointer<FwLoader>> m_modelList;
    QHash<int, QByteArray> m_roles;
    int m_idx;

private:
    // QAbstractListModel implementation
    int rowCount(const QModelIndex &parent = QModelIndex()) const;
    QHash<int, QByteArray> roleNames() const;

private:
    FwModel(const FwModel&);
    FwModel& operator=(const FwModel&);

private slots:
    void onChanged();
    void onChecked();
    void onLoaded();
    void onError();

public:
    explicit FwModel(QObject *parent = nullptr);
    ~FwModel();

    // QAbstractListModel implementation
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;     // used by View

signals:
    void checked();
    void loaded();
    void error();

public slots:
    void setLink(trans::SerialClient *ptr);
    void reload(const QString &cfgPath, const QString &fwPath);

    void addItem(QSharedPointer<FwLoader> ptr);
    void addItem(const QJsonObject &cfg, const QString &fileName, const QByteArray &fw);
    int size() const { return m_modelList.size(); }
    void clear();

    void checkFw();
    void loadFw();
    void resetCheckStatus();
    void resetLoadStatus();
};


}    // namespace stand


#endif // FWMODEL_H
