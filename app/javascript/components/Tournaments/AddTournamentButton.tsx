import { Button, DatePicker, Form, Input, Modal, message } from "antd";
import { FormComponentProps } from "antd/lib/form";
import moment from "moment";
import * as React from "react";
import Api from "../../api/Api";
import TournamentRequests from "../../api/requests/TournamentRequests";
import { TournamentEvents } from "../../events/TournamentEvents";
import { authenticated } from "../../helpers/AuthenticationHOC";
import IAPITournament from "../../entities/ITournament";

interface IAddButtonState {
  isModalOpen: boolean;
  isWorking: boolean;
}

class AddTournamentButton extends React.Component<FormComponentProps, IAddButtonState> {
  public state: IAddButtonState = {
    isModalOpen: false,
    isWorking: false,
  };

  private form: Form;

  public render() {
    const { isModalOpen, isWorking } = this.state;
    const { getFieldDecorator } = this.props.form;

    return (
      <Button type="primary" className="w-100 p-0" title="Create tournament" onClick={this.onAdd}>
        <i className="material-icons">add</i>

        <Modal
          destroyOnClose={true}
          closable={true}
          maskClosable={false}
          visible={isModalOpen}
          onCancel={this.onCancel}
          onOk={this.onCreate}
          confirmLoading={isWorking}
          title="Create tournament"
        >
          <Form onSubmit={this.onCreate} ref={f => this.form = f}>
            <Form.Item label="Name">
              {
                getFieldDecorator(
                  "name",
                  { rules: [{ required: true, message: "Please enter a tournament anem!" }] },
                )(<Input placeholder="Tournament name" name="name" />)
              }
            </Form.Item>
            <Form.Item label="RangePicker">
              {
                getFieldDecorator(
                  "duration",
                  { rules: [{ type: "array", required: true, message: "Please select dates!" }] },
                )(<DatePicker.RangePicker name="duration" />)
              }
            </Form.Item>
          </Form>
        </Modal>
      </Button>
    );
  }

  private setModalVisibility = (visible: boolean) => this.setState({ isModalOpen: visible });

  private onAdd = () => this.setModalVisibility(true);

  private onCancel = () => this.setModalVisibility(false);

  private onCreate = async (e: React.MouseEvent | React.FormEvent) => {
    e.preventDefault();

    const { form } = this.props;

    const { error, values } = await new Promise(resolve => form.validateFieldsAndScroll((err, v) => resolve({ error: err, values: v })));

    if (error) {
      return;
    }

    this.setState({ isWorking: true });

    const [startDate, endDate] = values.duration;

    try {
      const request = TournamentRequests.createTournament({
        endDate: endDate.toISOString(),
        name: values.name,
        startDate: startDate.toISOString(),
      });

      const response = await Api.performRequest<IAPITournament>(request);

      form.resetFields();
      this.setModalVisibility(false);

      $(document).trigger(TournamentEvents.Created);
      message.success(`Tournament "${response.name}" created!`);
    } catch (e) {
      message.error(e.message);
    } finally {
      this.setState({ isWorking: false });
    }
  }
}

const WrappedAddButtonForm = Form.create({ name: "add_tournament" })(AddTournamentButton);

export default authenticated(WrappedAddButtonForm);
