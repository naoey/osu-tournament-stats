import { Button, DatePicker, Form, Input, Modal } from "antd";
import { FormComponentProps } from "antd/lib/form";
import moment from "moment";
import * as React from "react";
import { authenticated } from "../../helpers/AuthenticationHOC";
import IPlayer from "../../types/IPlayer";
import Api from "../../api/Api";
import ITournament from "../../types/ITournament";
import Tournaments from "../../api/requests/Tournaments";
import { TournamentEvents } from "../../events/TournamentEvents";

interface IAddButtonState {
  isModalOpen: boolean;
  isWorking: boolean;
}

class AddButton extends React.Component<FormComponentProps, IAddButtonState> {
  public state: IAddButtonState = {
    isModalOpen: false,
    isWorking: false,
  };

  private form: Form;

  public render() {
    const { isModalOpen, isWorking } = this.state;
    const { getFieldDecorator } = this.props.form;

    return (
      <Button type="primary" className="w-100" onClick={this.onAdd}>
        <i className="material-icons">add</i>
        <span>Add tournament</span>

        <Modal
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

    const [startDate, endDate] = values.duration;

    try {
      const request = Tournaments.createTournament({
        endDate: endDate.toISOString(),
        name: values.name,
        startDate: startDate.toISOString(),
      });

      const response = await Api.performRequest<ITournament>(request);

      form.resetFields();
      this.setModalVisibility(false);

      $(document).trigger(TournamentEvents.Created);
    } catch (e) {
      console.error(e);
    }
  }
}

const WrappedAddButtonForm = Form.create({ name: "add_tournament" })(AddButton);

export default authenticated(WrappedAddButtonForm);
