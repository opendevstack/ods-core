import datetime

from sqlalchemy import Column, Integer, Enum, DateTime, Text
from sqlalchemy.orm import Session

from airflow.models import Base
from airflow.utils.db import provide_session


class OpenShiftSyncRequest(Base):
    STATUS_FAILED = "FAILED"
    STATUS_COMPLETED = "COMPLETED"
    STATUS_REQUESTED = "REQUESTED"

    COMPONENT_WEBSERVER = "WEBSERVER"
    COMPONENT_SCHEDULER = "SCHEDULER"

    __tablename__ = "openshift_sync_request"

    id = Column(Integer, primary_key=True)
    status = Column(Enum(STATUS_REQUESTED, STATUS_COMPLETED, STATUS_FAILED,
                         name="OpenShiftSyncRequestStatus"),
                    default=STATUS_REQUESTED)
    component = Column(Enum(COMPONENT_WEBSERVER, COMPONENT_SCHEDULER,
                            name="OpenShiftSyncAirflowComponent"),
                       default=COMPONENT_SCHEDULER)
    requested_at = Column(DateTime, default=datetime.datetime.now)
    executed_at = Column(DateTime,
                         default=datetime.datetime.now,
                         onupdate=datetime.datetime.now)
    status_message = Column(Text,
                            nullable=True)

    @classmethod
    @provide_session
    def create_table(cls, session: Session = None):
        cls.__table__.create(session.get_bind(), checkfirst=True)
