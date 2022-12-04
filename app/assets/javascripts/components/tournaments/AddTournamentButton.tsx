import * as React from "react";
import { Modal, Form, DatePicker, Button, Input, message } from "antd";
import TournamentRequests from "../../api/requests/TournamentRequests";
import Api from "../../api/Api";
import { Tournament } from "../../entities/Tournament";
import { authenticated } from "../../helpers/AuthenticationHOC";

function AddTournamentButton() {
  const [isFormVisible, setFormVisible] = React.useState(false);
  const [isWorking, setWorking] = React.useState(false);

  const [form] = Form.useForm();

  React.useEffect(() => {
    if (!isFormVisible)
      form.resetFields();
  }, [isFormVisible]);

  const showModal = () => setFormVisible(true);
  const hideModal = () => setFormVisible(false);

  const createTournament = async (values: any) => {
    setWorking(true);

    try {
      const request = TournamentRequests.createTournament({
        name: values.name,
        startDate: values.dates[0]?.toISOString() ?? null,
        endDate: values.dates[0]?.toISOString() ?? null,
      });
      const response = await Api.performRequest<Tournament>(request);

      message.success(`${response.name} created`);

      window.location.href = `/tournaments/${response.id}`;
    } catch (e: any) {
      message.error(e.message);
      setWorking(false);
    }
  }

  return (
    <React.Fragment>
      <Button onClick={showModal} type="primary" className="ot-btn">
        <i className="material-icons">add</i>
      </Button>
      <Modal
        visible={isFormVisible}
        title="Add match"
        onCancel={hideModal}
        onOk={form.submit}
        confirmLoading={isWorking}
      >
        <Form form={form} onFinish={createTournament}>
          <Form.Item name="name" label="Name" required={true}>
            <Input type="text" />
          </Form.Item>
          <Form.Item name="dates" label="Schedule">
            <DatePicker.RangePicker />
          </Form.Item>
        </Form>
      </Modal>
    </React.Fragment>
  );
}

export default authenticated(AddTournamentButton);
