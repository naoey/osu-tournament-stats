import { Button, DatePicker, Form, Input, message, Modal } from "antd";
import { FormComponentProps } from "antd/lib/form";
import * as React from "react";
import Api from "../../api/Api";
import TournamentRequests from "../../api/requests/TournamentRequests";
import ITournament from "../../entities/ITournament";
import { TournamentEvents } from "../../events/TournamentEvents";
import { authenticated } from "../../helpers/AuthenticationHOC";

interface IAddButtonState {
  isModalOpen: boolean;
  isWorking: boolean;
}

class AddMatchButton extends React.Component<FormComponentProps, IAddButtonState> {
  public state: IAddButtonState = {
    isModalOpen: false,
    isWorking: false,
  };

  public render() {
    const { isModalOpen, isWorking } = this.state;
    const { getFieldDecorator } = this.props.form;

    return (
      <Button type="primary" className="w-100 p-0" title="Create tournament" onClick={this.onAdd}>
        <span><i className="material-icons">add</i> Add match</span>

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
          <Form onSubmit={this.onCreate}>
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
                  "matchId",
                  { rules: [{ type: "array", required: true, message: "Please select dates!" }] },
                )(<Input type="number" placeholder="osu! multiplayer ID" />)
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

    // const { form } = this.props;

    // const { error, values } = await new Promise(resolve => form.validateFieldsAndScroll((err, v) => resolve({ error: err, values: v })));

    // if (error) return;

    // this.setState({ isWorking: true });

    // const [startDate, endDate] = values.duration;

    // try {
    //   const request = TournamentRequests.createTournament({
    //     endDate: endDate.toISOString(),
    //     name: values.name,
    //     startDate: startDate.toISOString(),
    //   });

    //   const response = await Api.performRequest<ITournament>(request);

    //   form.resetFields();
    //   this.setModalVisibility(false);

    //   $(document).trigger(TournamentEvents.Created);
    //   message.success(`Tournament "${response.name}" created!`);
    // } catch (e) {
    //   message.error(e.message);
    // } finally {
    //   this.setState({ isWorking: false });
    // }
  }
}

const WrappedAddButtonForm = Form.create({ name: "add_match" })(AddMatchButton);

export default authenticated(WrappedAddButtonForm);
